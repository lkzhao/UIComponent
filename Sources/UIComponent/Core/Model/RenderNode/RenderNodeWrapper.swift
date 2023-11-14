//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/23/23.
//

import Foundation

public protocol RenderNodeWrapper: RenderNode {
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
    public var shouldRenderView: Bool {
        content.shouldRenderView
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
    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        content.visibleIndexes(in: frame)
    }
    public func updateView(_ view: Content.View) {
        content.updateView(view)
    }
    public func makeView() -> Content.View {
        content.makeView()
    }
}
