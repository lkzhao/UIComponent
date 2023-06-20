//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct VisibleFrameInsets: Component {
    let child: any Component
    let insets: UIEdgeInsets

    public init(child: any Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        VisibleFrameInsetRenderNode(child: child.layout(constraint), insets: insets)
    }
}

public struct DynamicVisibleFrameInset: Component {
    let child: any Component
    let insetProvider: (CGRect) -> UIEdgeInsets

    public init(child: any Component, insetProvider: @escaping (CGRect) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVisibleFrameInsetRenderNode(child: child.layout(constraint), insetProvider: insetProvider)
    }
}

struct VisibleFrameInsetRenderNode: RenderNode {
    typealias View = NeverView

    let child: any RenderNode
    let insets: UIEdgeInsets

    var size: CGSize { child.size }
    var children: [any RenderNode] { child.children }
    var positions: [CGPoint] { child.positions }
    func visibleIndexes(in frame: CGRect) -> IndexSet {
        child.visibleIndexes(in: frame.inset(by: insets))
    }
}

struct DynamicVisibleFrameInsetRenderNode: RenderNode {
    typealias View = NeverView

    let child: any RenderNode
    let insetProvider: (CGRect) -> UIEdgeInsets

    var size: CGSize { child.size }
    var children: [any RenderNode] { child.children }
    var positions: [CGPoint] { child.positions }
    func visibleIndexes(in frame: CGRect) -> IndexSet {
        child.visibleIndexes(in: frame.inset(by: insetProvider(frame)))
    }
}
