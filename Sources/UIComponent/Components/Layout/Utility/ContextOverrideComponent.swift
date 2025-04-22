//  Created by Luke Zhao on 8/23/20.

import UIKit

/// Wraps a content component and overrides its context with the specified values.
public struct ContextOverrideComponent<Content: Component>: Component {

    /// The context that overrides the default context of the content node.
    public let overrideContext: [RenderNodeContextKey: Any]

    /// The content component that this component wraps.
    public let content: Content

    /// Lays out the content component with the specified constraints.
    public func layout(_ constraint: Constraint) -> ContextOverrideRenderNode<Content.R> {
        ContextOverrideRenderNode(overrideContext: overrideContext,
                                  content: content.layout(constraint))
    }
}

public struct ContextOverrideRenderNode<Content: RenderNode>: RenderNodeWrapper {
    /// The context that overrides the default context of the content node.
    public let overrideContext: [RenderNodeContextKey: Any]

    /// The content node that this render node wraps.
    public let content: Content

    public var context: [RenderNodeContextKey : Any] {
        content.context.merging(overrideContext, uniquingKeysWith: { $1 })
    }
}
