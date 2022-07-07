//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct VisibleFrameInsets: Component {
    let child: Component
    let insets: UIEdgeInsets

    public init(child: Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> RenderNode {
        VisibleFrameInsetRenderNode(child: child.layout(constraint), insets: insets)
    }
}

public struct DynamicVisibleFrameInset: Component {
    let child: Component
    let insetProvider: (CGRect) -> UIEdgeInsets

    public init(child: Component, insetProvider: @escaping (CGRect) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> RenderNode {
        DynamicVisibleFrameInsetRenderNode(child: child.layout(constraint), insetProvider: insetProvider)
    }
}

struct VisibleFrameInsetRenderNode: RenderNode {
    let child: RenderNode
    let insets: UIEdgeInsets
    var size: CGSize {
        child.size
    }
    var children: [RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [.zero]
    }
    func visibleRenderables(in frame: CGRect) -> [Renderable] {
        child.visibleRenderables(in: frame.inset(by: insets))
    }
}

struct DynamicVisibleFrameInsetRenderNode: RenderNode {
    let child: RenderNode
    let insetProvider: (CGRect) -> UIEdgeInsets
    var size: CGSize {
        child.size
    }
    var children: [RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [.zero]
    }
    func visibleRenderables(in frame: CGRect) -> [Renderable] {
        child.visibleRenderables(in: frame.inset(by: insetProvider(frame)))
    }
}
