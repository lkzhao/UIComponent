//  Created by Luke Zhao on 8/23/20.

@_implementationOnly import BaseToolbox
import UIKit

public struct Insets: Component {
    let child: Component
    let insets: UIEdgeInsets
    public init(child: Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }
    public func layout(_ constraint: Constraint) -> RenderNode {
        InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

public struct DynamicInsets: Component {
    let child: Component
    let insetProvider: (Constraint) -> UIEdgeInsets
    public init(child: Component, insetProvider: @escaping (Constraint) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }
    public func layout(_ constraint: Constraint) -> RenderNode {
        let insets = insetProvider(constraint)
        return InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

struct InsetsRenderNode: RenderNode {
    let child: RenderNode
    let insets: UIEdgeInsets
    var size: CGSize {
        child.size.inset(by: -insets)
    }
    var children: [RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [CGPoint(x: insets.left, y: insets.top)]
    }
}
