//  Created by Luke Zhao on 8/27/20.

@_implementationOnly import BaseToolbox
import UIKit

public protocol ComponentReloadDelegate: AnyObject {
    func componentViewShouldReload(_ view: ComponentDisplayableView) -> Bool
}

/// Main class that powers rendering components
///
/// This object manages a ``ComponentDisplayableView`` and handles rendering the component
/// to the view. See ``ComponentView`` for a sample implementation
public class ComponentEngine {
    // force view update to be performed within a UIView.performWithoutAnimation block
    public static var disableUpdateAnimation: Bool = false
    public static weak var reloadDelegate: ComponentReloadDelegate?
    
    /// view that is managed by this engine.
    weak var view: ComponentDisplayableView?

    /// component for rendering
    var component: Component? {
        didSet { setNeedsReload() }
    }

    /// default animator for the components rendered by this engine
    var animator: Animator = Animator() {
        didSet { setNeedsReload() }
    }

    /// Current renderNode. This is nil before the layout is done. And it will cache the current RenderNode once the layout is done.
    var renderNode: RenderNode?

    /// internal states
    var needsReload = true
    var needsRender = false
    var shouldSkipNextLayout = false
    var reloadCount = 0
    var isRendering = false
    var isReloading = false
    var allowReload: Bool {
        guard let view, let reloadDelegate = Self.reloadDelegate else { return true }
        return reloadDelegate.componentViewShouldReload(view)
    }

    /// visible frame insets. this will be applied to the visibleFrame that is used to retrieve views for the view port.
    var visibleFrameInsets: UIEdgeInsets = .zero

    /// simple flag indicating whether or not this engine has rendered
    var hasReloaded: Bool { reloadCount > 0 }

    /// visible cells and view data for the views displayed on screen
    var visibleViews: [UIView] = []
    var visibleRenderable: [Renderable] = []

    /// last reload bounds
    var lastRenderBounds: CGRect = .zero

    /// contentOffset changes since the last reload
    var contentOffsetDelta: CGPoint = .zero

    var onFirstReload: (() -> Void)?

    /// Used to support zooming. setting a ``contentView`` will make the render
    /// all views inside the content view.
    var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView {
                view?.addSubview(contentView)
            }
        }
    }

    /// contentView layout configurations
    var centerContentViewVertically = false
    var centerContentViewHorizontally = true

    /// internal helpers for updating the component view
    var contentSize: CGSize = .zero {
        didSet {
            (view as? UIScrollView)?.contentSize = contentSize
        }
    }
    var contentOffset: CGPoint {
        get { return view?.bounds.origin ?? .zero }
        set { view?.bounds.origin = newValue }
    }
    var contentInset: UIEdgeInsets {
        guard let view = view as? UIScrollView else { return .zero }
        return view.adjustedContentInset
    }
    var bounds: CGRect {
        guard let view = view else { return .zero }
        return view.bounds
    }
    var adjustedSize: CGSize {
        bounds.size.inset(by: contentInset)
    }
    var zoomScale: CGFloat {
        guard let view = view as? UIScrollView else { return 1 }
        return view.zoomScale
    }

    init(view: ComponentDisplayableView) {
        self.view = view
    }

    func layoutSubview() {
        if needsReload {
            reloadData()
        } else if bounds.size != lastRenderBounds.size {
            invalidateLayout()
        } else if bounds != lastRenderBounds || needsRender {
            render()
        }
        contentView?.frame = CGRect(origin: .zero, size: contentSize)
        ensureZoomViewIsCentered()
    }

    func ensureZoomViewIsCentered() {
        guard let contentView = contentView else { return }
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

    func setNeedsReload() {
        needsReload = true
        view?.setNeedsLayout()
    }

    func setNeedsInvalidateLayout() {
        renderNode = nil
        setNeedsRender()
    }

    func setNeedsRender() {
        needsRender = true
        view?.setNeedsLayout()
    }

    // re-layout, but not reloads
    func invalidateLayout() {
        guard !isRendering, !isReloading, hasReloaded else { return }
        renderNode = nil
        render(updateViews: true)
    }

    // reload all frames. will automatically diff insertion & deletion
    func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        guard !isReloading, allowReload else { return }
        isReloading = true
        defer {
            reloadCount += 1
            needsReload = false
            isReloading = false
            if let onFirstReload, reloadCount == 1 {
                onFirstReload()
            }
        }

        if !shouldSkipNextLayout {
            renderNode = nil
        }
        shouldSkipNextLayout = false
        render(contentOffsetAdjustFn: contentOffsetAdjustFn, updateViews: true)
    }

    func render(contentOffsetAdjustFn: (() -> CGPoint)? = nil, updateViews: Bool = false) {
        guard let componentView = view, !isRendering, let component = component else { return }
        isRendering = true
        defer {
            needsRender = false
            isRendering = false
        }

        ComponentViewMananger.shared.push(view: componentView)
        let renderNode: RenderNode
        if let currentRenderNode = self.renderNode {
            renderNode = currentRenderNode
        } else {
            renderNode = component.layout(Constraint(maxSize: adjustedSize))
            contentSize = renderNode.size * zoomScale
            self.renderNode = renderNode
        }

        let oldContentOffset = contentOffset
        if let offset = contentOffsetAdjustFn?() {
            contentOffset = offset
        }
        contentOffsetDelta = contentOffset - oldContentOffset

        animator.willUpdate(componentView: componentView)
        let visibleFrame = (contentView?.convert(bounds, from: view) ?? bounds).inset(by: visibleFrameInsets)

        var newVisibleRenderable = renderNode.visibleRenderables(in: visibleFrame)
        ComponentViewMananger.shared.pop()
        if contentSize != renderNode.size * zoomScale {
            // update contentSize if it is changed. Some renderNodes update
            // its size when visibleRenderables(in: visibleFrame) is called. e.g. InfiniteLayout
            contentSize = renderNode.size * zoomScale
        }

        // construct private identifiers
        var newIdentifierSet = [String: Int]()
        for (index, viewData) in newVisibleRenderable.enumerated() {
            var count = 1
            let initialId = viewData.id ?? viewData.keyPath
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
            let identifier = visibleRenderable[index].id ?? visibleRenderable[index].keyPath
            let cell = visibleViews[index]
            if let index = newIdentifierSet[identifier] {
                newViews[index] = cell
            } else {
                let animator = visibleRenderable[index].animator ?? animator
                animator.shift(componentView: componentView, delta: contentOffsetDelta, view: cell)
                animator.delete(componentView: componentView, view: cell) {
                    cell.recycleForUIComponentReuse()
                }
            }
        }

        // 2nd pass, insert new views
        for (index, viewData) in newVisibleRenderable.enumerated() {
            let view: UIView
            let frame = viewData.frame
            let animator = viewData.animator ?? animator
            let containerView = contentView ?? componentView
            if let existingView = newViews[index] {
                view = existingView
                if updateViews {
                    // view was on screen before reload, need to update the view.
                    viewData.renderNode._updateView(view)
                    animator.shift(componentView: componentView, delta: contentOffsetDelta, view: view)
                }
            } else {
                view = viewData.renderNode._makeView() as! UIView
                UIView.performWithoutAnimation {
                    view.bounds.size = frame.bounds.size
                    view.center = frame.center
                    if ComponentEngine.disableUpdateAnimation {
                        viewData.renderNode._updateView(view)
                    }
                }
                if !ComponentEngine.disableUpdateAnimation {
                    viewData.renderNode._updateView(view)
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
    }

    /// This is used to replace a cell's identifier with a new identifer
    /// Useful when a cell's identifier is going to change with the next
    /// reloadData, but you want to keep the same cell view.
    public func replace(identifier: String, with newIdentifier: String) {
        for (i, viewData) in visibleRenderable.enumerated() where viewData.id == identifier {
            visibleRenderable[i].id = newIdentifier
            break
        }
    }

    /// This function assigns component with an already calculated render node
    /// This is a performance hack that skips layout for the component if it has already
    /// been layed out.
    public func reloadWithExisting(component: Component, renderNode: RenderNode) {
        self.component = component
        self.renderNode = renderNode
        self.shouldSkipNextLayout = true
    }

    /// calculate the size for the current component
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return component?.layout(Constraint(maxSize: size)).size ?? .zero
    }
}
