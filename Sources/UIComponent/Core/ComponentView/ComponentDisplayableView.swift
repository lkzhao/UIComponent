//  Created by Luke Zhao on 2016-02-12.

import UIKit

public protocol ComponentDisplayableView: UIView {
    var engine: ComponentEngine { get }
}

extension ComponentDisplayableView {

    /// component to be rendered by this component displayable view
    public var component: Component? {
        get { engine.component }
        set { engine.component = newValue }
    }

    /// default animator for the component being rendered by this view
    public var animator: Animator {
        get { engine.animator }
        set { engine.animator = newValue }
    }

    /// visible frame insets that is applied to the view port before fetching the views from the renderNode
    public var visibleFrameInsets: UIEdgeInsets {
        get { engine.visibleFrameInsets }
        set { engine.visibleFrameInsets = newValue }
    }

    /// how many times this view has reloaded
    public var reloadCount: Int {
        engine.reloadCount
    }

    /// whether or not this view is going to reload when the next layout cycle happens.
    public var needsReload: Bool {
        engine.needsReload
    }

    /// whether or not this view is going to render when the next layout cycle happens.
    public var needsRender: Bool {
        engine.needsRender
    }

    /// whether or not this view currently reloading
    public var isReloading: Bool {
        engine.isReloading
    }

    /// whether or not this view currently rendering
    public var isRendering: Bool {
        engine.isRendering
    }

    /// whether or not this view has reloaded
    public var hasReloaded: Bool { reloadCount > 0 }

    /// visible views being rendered by this view.
    public var visibleViews: [UIView] {
        engine.visibleViews
    }

    /// visible renderable being rendered by this view
    public var visibleRenderable: [Renderable] {
        engine.visibleRenderable
    }

    /// bounds of this view when last render happens
    public var lastRenderBounds: CGRect {
        engine.lastRenderBounds
    }

    /// contentOffset changes since the last reload
    public var contentOffsetDelta: CGPoint {
        engine.contentOffsetDelta
    }

    /// mark this view as needing for a reload
    public func setNeedsReload() {
        engine.setNeedsReload()
    }
    /// mark this view as needing for a reload
    public func setNeedsInvalidateLayout() {
        engine.setNeedsInvalidateLayout()
    }
    public func setNeedsRender() {
        engine.setNeedsRender()
    }
    public func ensureZoomViewIsCentered() {
        engine.ensureZoomViewIsCentered()
    }
    public func invalidateLayout() {
        engine.invalidateLayout()
    }
    public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        engine.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
    }
}

extension ComponentDisplayableView {
    public func view(at point: CGPoint) -> UIView? {
        visibleViews.first {
            $0.point(inside: $0.convert(point, from: self), with: nil)
        }
    }
    public func frame(id: String) -> CGRect? {
        engine.renderNode?.frame(id: id)
    }
    public func visibleView(id: String) -> UIView? {
        for (view, renderNode) in zip(visibleViews, visibleRenderable) {
            if renderNode.id == id {
                return view
            }
        }
        return nil
    }
}
