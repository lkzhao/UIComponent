//  Created by Luke Zhao on 8/23/20.


import UIKit
/// Wraps a content component and applies the specified edge insets to it.
/// Instead of creating an instance directly, use the ``Component/inset(by:)`` modifier.
public struct Insets: Component {
    let content: any Component
    let insets: UIEdgeInsets

    /// Initializes a new Insets component with a content component and specific edge insets.
    /// - Parameters:
    ///   - content: The content component to apply insets to.
    ///   - insets: The edge insets to apply to the content component.
    public init(content: any Component, insets: UIEdgeInsets) {
        self.content = content
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        InsetsRenderNode(content: content.layout(constraint.inset(by: insets)), insets: insets)
    }
}

/// Wraps a content component and applies insets that can change based on the given constraints.
/// Instead of creating an instance directly, use the ``Component/inset(_:)-1mpsn`` modifier.
public struct DynamicInsets: Component {
    let content: any Component
    let insetProvider: (Constraint) -> UIEdgeInsets

    /// Initializes a new DynamicInsets component with a content component and an inset provider.
    /// - Parameters:
    ///   - content: The content component to apply dynamic insets to.
    ///   - insetProvider: A closure that provides edge insets based on the given constraints.
    public init(content: any Component, insetProvider: @escaping (Constraint) -> UIEdgeInsets) {
        self.content = content
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let insets = insetProvider(constraint)
        return InsetsRenderNode(content: content.layout(constraint.inset(by: insets)), insets: insets)
    }
}

/// A render node that represents a view with insets.
/// It contains a content render node and applies the specified edge insets to it.
struct InsetsRenderNode: RenderNode {
    typealias View = UIView

    let content: any RenderNode
    let insets: UIEdgeInsets

    /// The size of the render node, adjusted for the insets.
    var size: CGSize {
        content.size.inset(by: -insets)
    }

    /// The content render nodes of this render node.
    var children: [any RenderNode] {
        [content]
    }

    /// The positions of the content render nodes within this render node.
    var positions: [CGPoint] {
        [CGPoint(x: insets.left, y: insets.top)]
    }
}
