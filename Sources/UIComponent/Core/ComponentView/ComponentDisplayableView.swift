//  Created by Luke Zhao on 2016-02-12.

import UIKit

/// A protocol that defines a view capable of displaying components.
public protocol ComponentDisplayableView: UIView {
    var engine: ComponentEngine { get }
}

/// Extension to provide default implementations and additional functionalities to `ComponentDisplayableView`.
extension ComponentDisplayableView {

    /// The component to be rendered by this component displayable view.
    public var component: (any Component)? {
        get { engine.component }
        set { engine.component = newValue }
    }

    /// The default animator for the component being rendered by this view.
    public var animator: Animator {
        get { engine.animator }
        set { engine.animator = newValue }
    }
    
    /// The render node associated with the current component.
    public var renderNode: (any RenderNode)? {
        engine.renderNode
    }

    /// The visible frame insets that are applied to the viewport before fetching the views from the renderNode.
    public var visibleFrameInsets: UIEdgeInsets {
        get { engine.visibleFrameInsets }
        set { engine.visibleFrameInsets = newValue }
    }

    /// The number of times this view has reloaded.
    public var reloadCount: Int {
        engine.reloadCount
    }

    /// A Boolean value indicating whether this view is scheduled to reload during the next layout cycle.
    public var needsReload: Bool {
        engine.needsReload
    }

    /// A Boolean value indicating whether this view is scheduled to render during the next layout cycle.
    public var needsRender: Bool {
        engine.needsRender
    }

    /// A Boolean value indicating whether this view is currently reloading.
    public var isReloading: Bool {
        engine.isReloading
    }

    /// A Boolean value indicating whether this view is currently rendering.
    public var isRendering: Bool {
        engine.isRendering
    }

    /// A Boolean value indicating whether this view has reloaded at least once.
    public var hasReloaded: Bool { reloadCount > 0 }

    /// The views that are currently visible and being rendered by this view.
    public var visibleViews: [UIView] {
        engine.visibleViews
    }

    /// The renderables that are currently visible and being rendered by this view.
    public var visibleRenderable: [Renderable] {
        engine.visibleRenderable
    }

    /// The bounds of this view when the last render occurred.
    public var lastRenderBounds: CGRect {
        engine.lastRenderBounds
    }

    /// The content offset changes since the last reload.
    public var contentOffsetDelta: CGPoint {
        engine.contentOffsetDelta
    }

    /// Marks this view as needing a reload.
    public func setNeedsReload() {
        engine.setNeedsReload()
    }

    /// Marks this view as needing an invalidation of its layout.
    public func setNeedsInvalidateLayout() {
        engine.setNeedsInvalidateLayout()
    }

    /// Marks this view as needing a render.
    public func setNeedsRender() {
        engine.setNeedsRender()
    }

    /// Ensures that the zoom view is centered.
    public func ensureZoomViewIsCentered() {
        engine.ensureZoomViewIsCentered()
    }

    /// Reloads the data and optionally adjusts the content offset.
    public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        engine.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
    }
}

/// Extension to provide additional functionalities to `ComponentDisplayableView` related to view lookup and frame calculation.
extension ComponentDisplayableView {
    /// Returns the view at a given point if it exists within the visible views.
    public func view(at point: CGPoint) -> UIView? {
        visibleViews.first {
            $0.point(inside: $0.convert(point, from: self), with: nil)
        }
    }

    /// Returns the frame associated with a given identifier if it exists within the render node.
    public func frame(id: String) -> CGRect? {
        engine.renderNode?.frame(id: id)
    }

    /// Returns the visible view associated with a given identifier if it exists within the visible renderables.
    public func visibleView(id: String) -> UIView? {
        for (view, renderable) in zip(visibleViews, visibleRenderable) {
            if renderable.renderNode.id == id {
                return view
            }
        }
        return nil
    }
}
