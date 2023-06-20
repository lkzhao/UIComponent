//  Created by Luke Zhao on 8/26/20.

import Foundation

public struct RenderNodeReader<ChildComponent: Component>: Component {
    let child: ChildComponent
    let reader: (ChildComponent.R) -> Void

    public init(child: ChildComponent, _ reader: @escaping (ChildComponent.R) -> Void) {
        self.child = child
        self.reader = reader
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let renderNode = child.layout(constraint)
        reader(renderNode)
        return renderNode
    }
}
