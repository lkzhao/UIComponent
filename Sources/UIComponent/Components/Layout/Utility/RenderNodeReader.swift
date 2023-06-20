//  Created by Luke Zhao on 8/26/20.

import Foundation

public struct RenderNodeReader: Component {
    let child: Component
    let reader: (any RenderNode) -> Void

    public init(child: Component, _ reader: @escaping (any RenderNode) -> Void) {
        self.child = child
        self.reader = reader
    }

    public func layout(_ constraint: Constraint) -> any RenderNode {
        let renderNode = child.layout(constraint)
        reader(renderNode)
        return renderNode
    }
}
