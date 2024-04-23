//
//  File.swift
//  
//
//  Created by Luke Zhao on 4/23/24.
//

import UIKit

/// Wraps a content component and applies the specified offset to it.
/// Instead of creating an instance directly, use the ``Component/offset(_:)`` modifier.
public struct Offset: Component {
    let content: any Component
    let offset: CGPoint

    public init(content: any Component, offset: CGPoint) {
        self.content = content
        self.offset = offset
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        OffsetRenderNode(content: content.layout(constraint), offset: offset)
    }
}

public struct DynamicOffset: Component {
    let content: any Component
    let offsetProvider: (Constraint) -> CGPoint

    public init(content: any Component, offsetProvider: @escaping (Constraint) -> CGPoint) {
        self.content = content
        self.offsetProvider = offsetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let offset = offsetProvider(constraint)
        return OffsetRenderNode(content: content.layout(constraint), offset: offset)
    }
}

struct OffsetRenderNode: RenderNode {
    typealias View = UIView

    let content: any RenderNode
    let offset: CGPoint

    /// The size of the render node, adjusted for the insets.
    var size: CGSize {
        content.size
    }

    /// The content render nodes of this render node.
    var children: [any RenderNode] {
        [content]
    }

    /// The positions of the content render nodes within this render node.
    var positions: [CGPoint] {
        [offset]
    }

    func visibleIndexes(in frame: CGRect) -> any Collection<Int> {
        [0]
    }

    func visibleRenderables(in frame: CGRect) -> [Renderable] {
        var result = [Renderable]()
        if shouldRenderView, frame.intersects(CGRect(origin: .zero, size: size)) {
            result.append(Renderable(frame: CGRect(origin: .zero, size: size), renderNode: self, fallbackId: defaultReuseKey))
        }
        let indexes = visibleIndexes(in: frame)
        for i in indexes {
            let child = children[i]
            let position = positions[i]
            let childRenderables = child.visibleRenderables(in: frame).map {
                Renderable(frame: $0.frame + position, renderNode: $0.renderNode, fallbackId: "item-\(i)-\($0.fallbackId)")
            }
            result.append(contentsOf: childRenderables)
        }
        return result
    }
}
