//  Created by Luke Zhao on 2016-02-12.

/// A helper protocol that provides easier access to the underlying component engine's methods
public protocol ComponentDisplayableView: UIView {}

/// Extension to provide easier access to the underlying component engine's methods
extension ComponentDisplayableView {

    /// The component to be rendered by this component displayable view.
    public var component: (any Component)? {
        get { componentEngine.component }
        set { componentEngine.component = newValue }
    }

    /// The default animator for the component being rendered by this view.
    public var animator: Animator {
        get { componentEngine.animator }
        set { componentEngine.animator = newValue }
    }

    /// A closure that is called after the first reload.
    public var onFirstReload: ((UIView) -> Void)? {
        get { componentEngine.onFirstReload }
        set { componentEngine.onFirstReload = newValue }
    }

    /// The render node associated with the current component.
    public var renderNode: (any RenderNode)? {
        componentEngine.renderNode
    }

    /// The visible frame insets that are applied to the viewport before fetching the views from the renderNode.
    public var visibleFrameInsets: UIEdgeInsets {
        get { componentEngine.visibleFrameInsets }
        set { componentEngine.visibleFrameInsets = newValue }
    }

    /// The number of times this view has reloaded.
    public var reloadCount: Int {
        componentEngine.reloadCount
    }

    /// A Boolean value indicating whether this view is scheduled to reload during the next layout cycle.
    public var needsReload: Bool {
        componentEngine.needsReload
    }

    /// A Boolean value indicating whether this view is scheduled to render during the next layout cycle.
    public var needsRender: Bool {
        componentEngine.needsRender
    }

    /// A Boolean value indicating whether this view is currently reloading.
    public var isReloading: Bool {
        componentEngine.isReloading
    }

    /// A Boolean value indicating whether this view is currently rendering.
    public var isRendering: Bool {
        componentEngine.isRendering
    }

    /// A Boolean value indicating whether this view has reloaded at least once.
    public var hasReloaded: Bool { reloadCount > 0 }

    /// The views that are currently visible and being rendered by this view.
    public var visibleViews: [UIView] {
        componentEngine.visibleViews
    }

    /// The renderables that are currently visible and being rendered by this view.
    public var visibleRenderable: [Renderable] {
        componentEngine.visibleRenderables
    }

    /// The bounds of this view when the last render occurred.
    public var lastRenderBounds: CGRect {
        componentEngine.lastRenderBounds
    }

    /// The content offset changes since the last reload.
    public var contentOffsetDelta: CGPoint {
        componentEngine.contentOffsetDelta
    }

    /// Marks this view as needing a reload.
    public func setNeedsReload() {
        componentEngine.setNeedsReload()
    }

    /// Marks this view as needing a render.
    public func setNeedsRender() {
        componentEngine.setNeedsRender()
    }

    /// Ensures that the zoom view is centered.
    public func ensureZoomViewIsCentered() {
        componentEngine.ensureZoomViewIsCentered()
    }

    /// Reloads the data and optionally adjusts the content offset.
    public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        componentEngine.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
    }

    /// Returns the view at a given point if it exists within the visible views.
    public func view(at point: CGPoint) -> UIView? {
        componentEngine.view(at: point)
    }

    /// Returns the frame associated with a given identifier if it exists within the render node.
    public func frame(id: String) -> CGRect? {
        componentEngine.frame(id: id)
    }

    /// Returns the visible view associated with a given identifier if it exists within the visible renderables.
    public func visibleView(id: String) -> UIView? {
        componentEngine.visibleView(id: id)
    }
}

extension ComponentDisplayableView where Self: PlatformScrollView {
    public var contentView: UIView? {
        get { componentEngine.contentView }
        set { componentEngine.contentView = newValue }
    }

    @discardableResult public func scrollTo(id: String, animated: Bool) -> Bool {
        componentEngine.scrollTo(id: id, animated: animated)
    }
}
