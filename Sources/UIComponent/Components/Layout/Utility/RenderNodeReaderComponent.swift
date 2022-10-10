//  Created by Luke Zhao on 8/26/20.

import Foundation

public struct RenderNodeReaderComponent: Component {
    let child: Component
    let reader: (RenderNode) -> Void

    public init(child: Component, _ reader: @escaping (RenderNode) -> Void) {
        self.child = child
        self.reader = reader
    }

    public func layout(_ constraint: Constraint) -> RenderNode {
        let renderNode = child.layout(constraint)
        reader(renderNode)
        return renderNode
    }
}
