//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct VisibleFrameInsets: Component {
    let child: Component
    let insets: UIEdgeInsets

    public init(child: Component, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> AnyRenderNode {
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

    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        DynamicVisibleFrameInsetRenderNode(child: child.layout(constraint), insetProvider: insetProvider)
    }
}

struct VisibleFrameInsetRenderNode: ViewRenderNode {
    typealias View = NeverView

    let child: AnyRenderNode
    let insets: UIEdgeInsets

    var size: CGSize { child.size }
    var children: [AnyRenderNode] { child.children }
    var positions: [CGPoint] { child.positions }
    func visibleIndexes(in frame: CGRect) -> IndexSet {
        child.visibleIndexes(in: frame.inset(by: insets))
    }
}

struct DynamicVisibleFrameInsetRenderNode: ViewRenderNode {
    typealias View = NeverView

    let child: AnyRenderNode
    let insetProvider: (CGRect) -> UIEdgeInsets

    var size: CGSize { child.size }
    var children: [AnyRenderNode] { child.children }
    var positions: [CGPoint] { child.positions }
    func visibleIndexes(in frame: CGRect) -> IndexSet {
        child.visibleIndexes(in: frame.inset(by: insetProvider(frame)))
    }
}
