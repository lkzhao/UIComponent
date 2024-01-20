//  Created by Luke Zhao on 8/26/20.

import Foundation

/// A `RenderNodeReader` is a component that allows reading the layout result of its child component.
/// It provides a mechanism to access the render node produced by the child component after layout.
public struct RenderNodeReader<ChildComponent: Component>: Component {
    /// The child component that this `RenderNodeReader` will use for layout.
    public let child: ChildComponent
    /// The closure that will be called with the layout result of the child component.
    public let reader: (ChildComponent.R) -> Void

    /// Initializes a new `RenderNodeReader` with a child component and a reader closure.
    /// - Parameters:
    ///   - child: The child component that will be laid out.
    ///   - reader: A closure that is called with the result of the child's layout.
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
