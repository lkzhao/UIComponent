//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/23/23.
//

import Foundation

/// A protocol that wraps a content `RenderNode` to and pass through all the render node methods.
/// Its render node methods can be overriden by the conforming type.
public protocol RenderNodeWrapper<Content>: RenderNode {
    associatedtype Content: RenderNode
    var content: Content { get }
}

extension RenderNodeWrapper {
    public var id: String? {
        content.id
    }
    public var animator: Animator? {
        content.animator
    }
    public var reuseStrategy: ReuseStrategy {
        content.reuseStrategy
    }
    public var size: CGSize {
        content.size
    }
    public var positions: [CGPoint] {
        content.positions
    }
    public var children: [any RenderNode] {
        content.children
    }
    public var shouldRenderView: Bool {
        content.shouldRenderView
    }
    public func visibleIndexes(in frame: CGRect) -> any Collection<Int> {
        content.visibleIndexes(in: frame)
    }
    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        content.visibleChildren(in: frame)
    }
    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        content.adjustVisibleFrame(frame: frame)
    }
    public func updateView(_ view: Content.View) {
        content.updateView(view)
    }
    public func makeView() -> Content.View {
        content.makeView()
    }
}
