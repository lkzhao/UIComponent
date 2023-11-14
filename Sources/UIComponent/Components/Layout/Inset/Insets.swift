//  Created by Luke Zhao on 8/23/20.

@_implementationOnly import BaseToolbox
import UIKit

public struct Insets: Component {
    let child: any Component
    let insets: UIEdgeInsets
    public init(child: any Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

public struct DynamicInsets: Component {
    let child: any Component
    let insetProvider: (Constraint) -> UIEdgeInsets
    public init(child: any Component, insetProvider: @escaping (Constraint) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        let insets = insetProvider(constraint)
        return InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
    }
}

struct InsetsRenderNode: RenderNode {
    typealias View = UIView

    let child: any RenderNode
    let insets: UIEdgeInsets
    var size: CGSize {
        child.size.inset(by: -insets)
    }
    var children: [any RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [CGPoint(x: insets.left, y: insets.top)]
    }
}
