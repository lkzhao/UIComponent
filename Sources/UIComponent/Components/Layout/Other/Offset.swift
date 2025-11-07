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

public struct OffsetRenderNode: RenderNode {
    public typealias View = UIView

    public let content: any RenderNode
    public let offset: CGPoint

    public init(content: any RenderNode, offset: CGPoint) {
        self.content = content
        self.offset = offset
    }

    /// The size of the render node, adjusted for the offset.
    public var size: CGSize {
        content.size
    }

    /// The ascender of the render node, adjusted for the offset.
    public var ascender: CGFloat {
        content.ascender + offset.y
    }

    /// The descender of the render node, adjusted for the offset.
    public var descender: CGFloat {
        content.descender + offset.y
    }

    /// The content render nodes of this render node.
    public var children: [any RenderNode] {
        [content]
    }

    /// The positions of the content render nodes within this render node.
    public var positions: [CGPoint] {
        [offset]
    }
}
