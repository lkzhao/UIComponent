//
//  ComponentDisplayable.swift
//  UIComponent
//
//  Created by Luke Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol ComponentDisplayableView: UIView {
    var engine: ComponentEngine { get }
}

public extension ComponentDisplayableView {
    
    /// component to be rendered by this component displayable view
    var component: Component? {
        get { engine.component }
        set { engine.component = newValue }
    }
    
    /// default animator for the component being rendered by this view
    var animator: Animator {
        get { engine.animator }
        set { engine.animator = newValue }
    }
    
    /// visible frame insets that is applied to the view port before fetching the views from the renderer
    var visibleFrameInsets: UIEdgeInsets {
        get { engine.visibleFrameInsets }
        set { engine.visibleFrameInsets = newValue }
    }
    
    /// how many times this view has reloaded
    var reloadCount: Int {
        engine.reloadCount
    }
    
    /// whether or not this view is going to reload when the next layout cycle happens.
    var needsReload: Bool {
        engine.needsReload
    }
    
    /// whether or not this view is going to render when the next layout cycle happens.
    var needsRender: Bool {
        engine.needsRender
    }
    
    /// whether or not this view currently reloading
    var isReloading: Bool {
        engine.isReloading
    }
    
    /// whether or not this view currently rendering
    var isRendering: Bool {
        engine.isRendering
    }
    
    /// whether or not this view has reloaded
    var hasReloaded: Bool { reloadCount > 0 }
    
    /// visible views being rendered by this view.
    var visibleViews: [UIView] {
        engine.visibleViews
    }
    
    /// visible renderable being rendered by this view
    var visibleRenderable: [Renderable] {
        engine.visibleRenderable
    }
    
    /// bounds of this view when last render happens
    var lastRenderBounds: CGRect {
        engine.lastRenderBounds
    }
    
    /// contentOffset changes since the last reload
    var contentOffsetDelta: CGPoint {
        engine.contentOffsetDelta
    }
    
    /// mark this view as needing for a reload
    func setNeedsReload() {
        engine.setNeedsReload()
    }
    /// mark this view as needing for a reload
    func setNeedsInvalidateLayout() {
        engine.setNeedsInvalidateLayout()
    }
    func setNeedsRender() {
        engine.setNeedsRender()
    }
    func ensureZoomViewIsCentered() {
        engine.ensureZoomViewIsCentered()
    }
    func invalidateLayout() {
        engine.invalidateLayout()
    }
    func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        engine.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
    }
}

public extension ComponentDisplayableView {
    func view(at point: CGPoint) -> UIView? {
        visibleViews.first {
            $0.point(inside: $0.convert(point, from: self), with: nil)
        }
    }
    func frame(id: String) -> CGRect? {
        engine.renderer?.frame(id: id)
    }
}
