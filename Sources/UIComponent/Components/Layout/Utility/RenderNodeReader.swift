//  Created by Luke Zhao on 8/26/20.

import Foundation

/// A `RenderNodeReader` is a component that allows reading the layout result of its content component.
/// It provides a mechanism to access the render node produced by the content component after layout.
public struct RenderNodeReader<ChildComponent: Component>: Component {
    /// The content component that this `RenderNodeReader` will use for layout.
    public let content: ChildComponent
    /// The closure that will be called with the layout result of the content component.
    public let reader: (ChildComponent.R) -> Void

    /// Initializes a new `RenderNodeReader` with a content component and a reader closure.
    /// - Parameters:
    ///   - content: The content component that will be laid out.
    ///   - reader: A closure that is called with the result of the content's layout.
    public init(content: ChildComponent, _ reader: @escaping (ChildComponent.R) -> Void) {
        self.content = content
        self.reader = reader
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let renderNode = content.layout(constraint)
        reader(renderNode)
        return renderNode
    }
}
