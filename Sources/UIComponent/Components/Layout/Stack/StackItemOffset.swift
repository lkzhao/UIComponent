//  Created by Luke Zhao on 7/29/24.

import simd

public struct VStackItemOffset: Component {
    public let offset: CGFloat
    public let stack: VStack
    public init(offset: CGFloat, stack: VStack) {
        self.offset = offset
        self.stack = stack
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        let renderNode = stack.layout(constraint)
        guard !renderNode.children.isEmpty else { return OffsetRenderNode(content: renderNode, offset: .zero) }
        let previousIndex = Int(offset).clamp(0, stack.children.count - 1)
        let nextIndex = min(previousIndex + 1, stack.children.count - 1)
        let previousPosition = renderNode.positions[previousIndex].y
        let nextPosition = nextIndex == previousIndex ? renderNode.positions[previousIndex].y + renderNode.children[previousIndex].size.height + stack.spacing : renderNode.positions[nextIndex].y
        let interpolatedOffset = simd_mix(previousPosition, nextPosition, offset - CGFloat(previousIndex))
        return OffsetRenderNode(content: renderNode, offset: CGPoint(x: 0, y: -interpolatedOffset))
    }
}

public extension VStack {
    func offsetByItem(_ offset: CGFloat) -> some Component {
        VStackItemOffset(offset: offset, stack: self)
    }
}

public struct HStackItemOffset: Component {
    public let offset: CGFloat
    public let stack: HStack
    public init(offset: CGFloat, stack: HStack) {
        self.offset = offset
        self.stack = stack
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        let renderNode = stack.layout(constraint)
        guard !renderNode.children.isEmpty else { return OffsetRenderNode(content: renderNode, offset: .zero) }
        let previousIndex = Int(offset).clamp(0, stack.children.count - 1)
        let nextIndex = min(previousIndex + 1, stack.children.count - 1)
        let previousPosition = renderNode.positions[previousIndex].x
        let nextPosition = nextIndex == previousIndex ? renderNode.positions[previousIndex].x + renderNode.children[previousIndex].size.width + stack.spacing : renderNode.positions[nextIndex].x
        let interpolatedOffset = simd_mix(previousPosition, nextPosition, offset - CGFloat(previousIndex))
        return OffsetRenderNode(content: renderNode, offset: CGPoint(x: -interpolatedOffset, y: 0))
    }
}

public extension HStack {
    func offsetByItem(_ offset: CGFloat) -> some Component {
        HStackItemOffset(offset: offset, stack: self)
    }
}
