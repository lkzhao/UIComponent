//  Created by Luke Zhao on 8/27/20.


import UIKit

/// Protocol defining a delegate responsible for determining if a component view should be reloaded.
public protocol ComponentReloadDelegate: AnyObject {
    /// Asks the delegate if the component view should be reloaded.
    /// - Parameter view: The `UIView` that is asking for permission to reload.
    /// - Returns: A Boolean value indicating whether the view should be reloaded.
    func componentViewShouldReload(_ view: UIView) -> Bool
}

/// `ComponentEngine` is the main class that powers the rendering of components.
/// It manages a `UIView` and handles rendering the component to the view.
/// See `ComponentView` for a sample implementation.
public final class ComponentEngine {
    /// A static property to disable animations during view updates.
    public static var disableUpdateAnimation: Bool = false
    
    /// A static weak reference to a delegate that decides if a component view should reload.
    public static weak var reloadDelegate: ComponentReloadDelegate?

    private static let asyncLayoutQueue = DispatchQueue(label: "com.component.layout", qos: .userInteractive)

    /// A flag indicating whether the layout should be performed asynchronously on a background thread
    public var asyncLayout = false

    /// The view that is managed by this engine.
    weak var view: UIView?

    /// The component that will be rendered.
    public var component: (any Component)? {
        didSet { setNeedsReload() }
    }

    /// The default animator for the components rendered by this engine.
    public var animator: Animator = BaseAnimator() {
        didSet { setNeedsRender() }
    }

    /// The current `RenderNode`. This is `nil` before the layout is done.
    public private(set) var renderNode: (any RenderNode)?

    /// Only render the renderNode, skipping layout.
    public private(set) var renderOnly: Bool = false

    /// Internal state to track if a reload is needed.
    public private(set) var needsReload = true

    /// Internal state to track if a render is needed.
    public private(set) var needsRender = false

    /// The number of times the view has been reloaded.
    public private(set) var reloadCount = 0

    /// Internal state to track if the engine is currently rendering.
    public private(set) var isRendering = false

    /// Internal state to track if the engine is currently reloading.
    public private(set) var isReloading = false

    /// A computed property to determine if reloading is allowed by consulting the `reloadDelegate`.
    var allowReload: Bool {
        guard let view, let reloadDelegate = Self.reloadDelegate else { return true }
        return reloadDelegate.componentViewShouldReload(view)
    }

    /// Insets for the visible frame. This will be applied to the `visibleFrame` used to retrieve views for the viewport.
    public var visibleFrameInsets: UIEdgeInsets = .zero

    /// A flag indicating whether this engine has rendered at least once.
    public var hasReloaded: Bool { reloadCount > 0 }

    /// An array of visible views on the screen.
    public private(set) var visibleViews: [UIView] = []

    /// An array of `Renderable` objects corresponding to the visible views.
    public private(set) var visibleRenderable: [Renderable] = []

    /// The bounds of the view during the last reload.
    public private(set) var lastRenderBounds: CGRect = .zero

    /// The change in content offset since the last reload.
    public private(set) var contentOffsetDelta: CGPoint = .zero

    /// A closure that is called after the first reload.
    public var onFirstReload: ((UIView) -> Void)?

    /// A view used to support zooming. Setting a `contentView` will render all views inside the content view.
    public var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView {
                view?.addSubview(contentView)
            }
        }
    }

    /// A Boolean value that determines if the content view should be centered vertically.
    public var centerContentViewVertically = false
    
    /// A Boolean value that determines if the content view should be centered horizontally.
    public var centerContentViewHorizontally = true

    /// The size of the content within the view.
    public private(set) var contentSize: CGSize = .zero {
        didSet {
            (view as? UIScrollView)?.contentSize = contentSize
        }
    }
    
    /// The offset of the scrolled content.
    var contentOffset: CGPoint {
        get { view?.bounds.origin ?? .zero }
        set { view?.bounds.origin = newValue }
    }
    
    /// The insets applied to the content of the view.
    var contentInset: UIEdgeInsets {
        (view as? UIScrollView)?.adjustedContentInset ?? .zero
    }
    
    /// The bounds of the view.
    var bounds: CGRect {
        view?.bounds ?? .zero
    }
    
    /// The size of the view adjusted for the content inset.
    var adjustedSize: CGSize {
        bounds.size.inset(by: contentInset)
    }
    
    /// The scale at which the content of the view is zoomed.
    var zoomScale: CGFloat {
        (view as? UIScrollView)?.zoomScale ?? 1
    }

    /// Initializes a new `ComponentEngine` with the given view.
    /// - Parameter view: The `UIView` to be managed by the engine.
    init(view: UIView) {
        self.view = view
    }

    /// Lays out the subview, reloading data if necessary or rendering if bounds have changed.
    func layoutSubview() {
        if needsReload || bounds.size != lastRenderBounds.size {
            reloadData()
        } else if bounds != lastRenderBounds || needsRender {
            render(updateViews: false)
        }
        contentView?.frame = CGRect(origin: .zero, size: contentSize)
        ensureZoomViewIsCentered()
    }

    /// Marks the view as needing a reload (layout + render) and schedules an update.
    public func setNeedsReload() {
        needsReload = true
        view?.setNeedsLayout()
    }

    /// Marks the view as needing a render (no layout) and schedules an update.
    /// A renderNode must be present
    public func setNeedsRender() {
        needsRender = true
        view?.setNeedsLayout()
    }

    /// Reloads the view, rendering the component.
    /// - Parameter contentOffsetAdjustFn: An optional closure that adjusts the content offset after the layout is finished, but berfore any view is rendered.
    public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        guard !isReloading, allowReload else { return }
        isReloading = true
        defer {
            reloadCount += 1
            needsReload = false
            isReloading = false
            if let onFirstReload, let view, reloadCount == 1 {
                onFirstReload(view)
            }
        }

        if renderOnly {
            adjustContentOffset(contentOffsetAdjustFn: contentOffsetAdjustFn)
            render(updateViews: true)
        } else if asyncLayout {
            layoutComponentAsync(contentOffsetAdjustFn: contentOffsetAdjustFn)
        } else {
            layoutComponent(contentOffsetAdjustFn: contentOffsetAdjustFn)
        }
    }

    private var asyncLayoutID: UUID?
    private func layoutComponentAsync(contentOffsetAdjustFn: (() -> CGPoint)?) {
        guard let componentView = view, let component else { return }

        let adjustedSize = adjustedSize
        let asyncLayoutID = UUID()
        self.asyncLayoutID = asyncLayoutID
        Self.asyncLayoutQueue.async { [weak self] in
            let renderNode = EnvironmentValues.with(values: .init(\.currentComponentView, value: componentView)) {
                component.layout(Constraint(maxSize: adjustedSize))
            }
            DispatchQueue.main.async {
                guard let self, self.asyncLayoutID == asyncLayoutID else { return }
                self.didFinishLayout(renderNode: renderNode, contentOffsetAdjustFn: contentOffsetAdjustFn)
            }
        }
    }

    private func layoutComponent(contentOffsetAdjustFn: (() -> CGPoint)?) {
        guard let componentView = view, let component else { return }

        let renderNode = EnvironmentValues.with(values: .init(\.currentComponentView, value: componentView)) {
            component.layout(Constraint(maxSize: adjustedSize))
        }
        
        didFinishLayout(renderNode: renderNode, contentOffsetAdjustFn: contentOffsetAdjustFn)
    }

    private func didFinishLayout(renderNode: any RenderNode, contentOffsetAdjustFn: (() -> CGPoint)?) {
        contentSize = renderNode.size * zoomScale
        self.renderNode = renderNode
        adjustContentOffset(contentOffsetAdjustFn: contentOffsetAdjustFn)
        render(updateViews: true)
    }

    private func adjustContentOffset(contentOffsetAdjustFn: (() -> CGPoint)?) {
        let oldContentOffset = contentOffset
        if let offset = contentOffsetAdjustFn?() {
            contentOffset = offset
        }
        contentOffsetDelta = contentOffset - oldContentOffset
    }

    /// Renders the render node based on the visibleFrame, optionally updating views.
    /// - Parameters:
    ///   - updateViews: A Boolean value that determines if the views should be updated.
    private func render(updateViews: Bool) {
        guard let componentView = view, allowReload, !isRendering, let renderNode else { return }
        isRendering = true

        animator.willUpdate(componentView: componentView)
        let visibleFrame = (contentView?.convert(bounds, from: view) ?? bounds).inset(by: visibleFrameInsets)

        var newVisibleRenderable = renderNode._visibleRenderables(in: visibleFrame)

        if contentSize != renderNode.size * zoomScale {
            // update contentSize if it is changed. Some renderNodes update
            // its size when visibleRenderables(in: visibleFrame) is called. e.g. InfiniteLayout
            contentSize = renderNode.size * zoomScale
        }

        // construct private identifiers
        var newIdentifierSet = [String: Int]()
        for (index, renderable) in newVisibleRenderable.enumerated() {
            var count = 1
            let initialId = renderable.id
            var finalId = initialId
            while newIdentifierSet[finalId] != nil {
                finalId = initialId + String(count)
                newVisibleRenderable[index].id = finalId
                count += 1
            }
            newIdentifierSet[finalId] = index
        }

        var newViews = [UIView?](repeating: nil, count: newVisibleRenderable.count)

        // 1st pass, delete all removed cells and move existing cells
        for index in 0..<visibleViews.count {
            let renderable = visibleRenderable[index]
            let id = renderable.id
            let cell = visibleViews[index]
            if let index = newIdentifierSet[id] {
                newViews[index] = cell
            } else {
                let animator = renderable.renderNode.animator ?? animator
                animator.shift(componentView: componentView, delta: contentOffsetDelta, view: cell)
                animator.delete(componentView: componentView, view: cell) {
                    cell.recycleForUIComponentReuse()
                }
            }
        }

        // 2nd pass, insert new views
        for (index, renderable) in newVisibleRenderable.enumerated() {
            let view: UIView
            let frame = renderable.frame
            let animator = renderable.renderNode.animator ?? animator
            let containerView = contentView ?? componentView
            if let existingView = newViews[index] {
                view = existingView
                if updateViews {
                    // view was on screen before reload, need to update the view.
                    renderable.renderNode._updateView(view)
                    animator.shift(componentView: componentView, delta: contentOffsetDelta, view: view)
                }
            } else {
                view = renderable.renderNode._makeView()
                UIView.performWithoutAnimation {
                    view.bounds.size = frame.bounds.size
                    view.center = frame.center
                    view.layoutIfNeeded()
                    if ComponentEngine.disableUpdateAnimation {
                        renderable.renderNode._updateView(view)
                    }
                }
                if !ComponentEngine.disableUpdateAnimation {
                    renderable.renderNode._updateView(view)
                }
                animator.insert(componentView: componentView, view: view, frame: frame)
                newViews[index] = view
            }
            animator.update(componentView: componentView, view: view, frame: frame)
            containerView.insertSubview(view, at: index)
        }

        visibleRenderable = newVisibleRenderable
        visibleViews = newViews as! [UIView]
        lastRenderBounds = bounds
        needsRender = false
        isRendering = false
    }

    /// Ensures that the zoom view is centered within the scroll view if it is smaller than the scroll view's bounds.
    public func ensureZoomViewIsCentered() {
        guard let contentView else { return }
        let boundsSize: CGRect
        boundsSize = bounds.inset(by: contentInset)
        var frameToCenter = contentView.frame

        if centerContentViewHorizontally, frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5
        } else {
            frameToCenter.origin.x = 0
        }

        if centerContentViewVertically, frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5
        } else {
            frameToCenter.origin.y = 0
        }

        contentView.frame = frameToCenter
    }

    /// Calculates the size that fits the current component within the given size.
    /// - Parameter size: The size within which the component should fit.
    /// - Returns: The size that fits the component.
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        component?.layout(Constraint(maxSize: size)).size ?? .zero
    }

    /// Replaces a cell's identifier with a new identifier.
    ///
    /// This is used to replace a cell's identifier with a new identifer
    /// Useful when a cell's identifier is going to change with the next
    /// reloadData, but you want to keep the same cell view.
    /// - Parameters:
    ///   - identifier: The current identifier of the cell.
    ///   - newIdentifier: The new identifier to replace the current identifier.
    public func replace(identifier: String, with newIdentifier: String) {
        for (i, renderable) in visibleRenderable.enumerated() where renderable.id == identifier {
            visibleRenderable[i].id = newIdentifier
            break
        }
    }

    /// Reloads the component with an existing render node, skipping reload.
    /// This is a performance hack that skips layout for the component if it has already been layed out.
    /// - Parameters:
    ///   - component: The component to be reloaded.
    ///   - renderNode: The existing render node to use for the reload.
    public func reloadWithExisting(component: any Component, renderNode: any RenderNode) {
        self.component = component
        self.renderNode = renderNode
        self.renderOnly = true
    }
}


/// Extension to provide additional functionalities to view lookup and frame calculation.
extension ComponentEngine {
    /// Returns the view at a given point if it exists within the visible views.
    public func view(at point: CGPoint) -> UIView? {
        guard let view else { return nil }
        return visibleViews.first {
            $0.point(inside: $0.convert(point, from: view), with: nil)
        }
    }

    /// Returns the frame associated with a given identifier if it exists within the render node.
    public func frame(id: String) -> CGRect? {
        renderNode?.frame(id: id)
    }

    /// Returns the visible view associated with a given identifier if it exists within the visible renderables.
    public func visibleView(id: String) -> UIView? {
        for (view, renderable) in zip(visibleViews, visibleRenderable) {
            if renderable.id == id {
                return view
            }
        }
        return nil
    }

    @discardableResult public func scrollTo(id: String, animated: Bool) -> Bool {
        if let frame = renderNode?.frame(id: id), let view = view as? UIScrollView {
            view.scrollRectToVisible(frame, animated: animated)
            return true
        } else {
            return false
        }
    }
}
