//  Created by Luke Zhao on 8/23/20.

import UIKit

/// Wraps a content component and overrides its context with the specified values.
public struct ContextOverrideComponent<Content: Component>: Component {
    /// The content component that this component wraps.
    public let content: Content

    /// The context that overrides the default context of the content node.
    public let overrideContext: [RenderNodeContextKey: Any]

    public init(content: Content, overrideContext: [RenderNodeContextKey: Any]) {
        self.overrideContext = overrideContext
        self.content = content
    }

    /// Lays out the content component with the specified constraints.
    public func layout(_ constraint: Constraint) -> ContextOverrideRenderNode<Content.R> {
        ContextOverrideRenderNode(content: content.layout(constraint),
                                  overrideContext: overrideContext)
    }
}

public struct ContextOverrideRenderNode<Content: RenderNode>: RenderNodeWrapper {
    /// The content node that this render node wraps.
    public let content: Content

    /// The context that overrides the default context of the content node.
    public let overrideContext: [RenderNodeContextKey: Any]

    public init(content: Content, overrideContext: [RenderNodeContextKey: Any]) {
        self.overrideContext = overrideContext
        self.content = content
    }

    public var context: [RenderNodeContextKey : Any] {
        content.context.merging(overrideContext, uniquingKeysWith: { $1 })
    }
}
