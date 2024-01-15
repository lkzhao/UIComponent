//  Created by Luke Zhao on 1/14/24.

import UIKit

public struct AnyRenderNode: RenderNode {
    public let erasing: any RenderNode
    public init(_ erasing: any RenderNode) {
        self.erasing = erasing
    }
    public var id: String? {
        erasing.id
    }
    public var animator: Animator? {
        erasing.animator
    }
    public var reuseStrategy: ReuseStrategy {
        erasing.reuseStrategy
    }
    public var shouldRenderView: Bool {
        erasing.shouldRenderView
    }
    public var size: CGSize {
        erasing.size
    }
    public var positions: [CGPoint] {
        erasing.positions
    }
    public var children: [any RenderNode] {
        erasing.children
    }
    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        erasing.visibleIndexes(in: frame)
    }
    public func updateView(_ view: UIView) {
        erasing._updateView(view)
    }
    public func makeView() -> UIView {
        erasing._makeView()
    }
}

extension RenderNode {
    public func eraseToAnyRenderNode() -> AnyRenderNode {
        AnyRenderNode(self)
    }
}
