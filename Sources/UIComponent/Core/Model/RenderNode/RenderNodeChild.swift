//  Created by Luke Zhao on 5/3/24.

import UIKit

/// A `RenderNodeChild` represents a child node of another RenderNode
/// It holds the child render node, its position within the parent, and its index within the parent.
public struct RenderNodeChild {
    /// The child render node
    public let renderNode: any RenderNode

    /// The position of the child within the parent.
    public let position: CGPoint

    /// The index of the child within the parent.
    /// This is not used for layout purposes, but for identifying the child for animations or updates. This is only used for structure identity when id is not present.
    public let index: Int

    /// Initializes a new `RenderNodeChild` with the given parameters.
    /// - Parameters:
    ///   - renderNode: The child render node.
    ///   - position: The position of the child within the parent.
    ///   - index: The index of the child within the parent.
    public init(renderNode: any RenderNode, position: CGPoint, index: Int) {
        self.renderNode = renderNode
        self.position = position
        self.index = index
    }
}

extension RenderNodeChild {
    public var frame: CGRect {
        CGRect(origin: position, size: renderNode.size)
    }
}
