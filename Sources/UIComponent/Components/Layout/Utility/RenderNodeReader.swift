//  Created by Luke Zhao on 8/26/20.

import Foundation

public struct RenderNodeReader: Component {
    let child: Component
    let reader: (AnyRenderNode) -> Void

    public init(child: Component, _ reader: @escaping (AnyRenderNode) -> Void) {
        self.child = child
        self.reader = reader
    }

    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        let renderNode = child.layout(constraint)
        reader(renderNode)
        return renderNode
    }
}
