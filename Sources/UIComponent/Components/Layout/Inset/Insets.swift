//  Created by Luke Zhao on 8/23/20.


import UIKit
/// Wraps a child component and applies the specified edge insets to it.
/// Instead of creating an instance directly, use the ``Component/inset(by:)`` modifier.
public struct Insets: Component {
    let child: any Component
    let insets: UIEdgeInsets

    /// Initializes a new Insets component with a child component and specific edge insets.
    /// - Parameters:
    ///   - child: The child component to apply insets to.
    ///   - insets: The edge insets to apply to the child component.
    public init(child: any Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

/// Wraps a child component and applies insets that can change based on the given constraints.
/// Instead of creating an instance directly, use the ``Component/inset(_:)-1mpsn`` modifier.
public struct DynamicInsets: Component {
    let child: any Component
    let insetProvider: (Constraint) -> UIEdgeInsets

    /// Initializes a new DynamicInsets component with a child component and an inset provider.
    /// - Parameters:
    ///   - child: The child component to apply dynamic insets to.
    ///   - insetProvider: A closure that provides edge insets based on the given constraints.
    public init(child: any Component, insetProvider: @escaping (Constraint) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let insets = insetProvider(constraint)
        return InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

/// A render node that represents a view with insets.
/// It contains a child render node and applies the specified edge insets to it.
struct InsetsRenderNode: RenderNode {
    typealias View = UIView

    let child: any RenderNode
    let insets: UIEdgeInsets

    /// The size of the render node, adjusted for the insets.
    var size: CGSize {
        child.size.inset(by: -insets)
    }

    /// The child render nodes of this render node.
    var children: [any RenderNode] {
        [child]
    }

    /// The positions of the child render nodes within this render node.
    var positions: [CGPoint] {
        [CGPoint(x: insets.left, y: insets.top)]
    }
}

