import UIKit

extension RenderNode {
    /// Creates a render node that overrides the identifier of the content.
    /// - Parameter id: An optional identifier to be set for the content.
    /// - Returns: An `ContextOverrideRenderNode` with the overridden identifier.
    public func id(_ id: String?) -> ContextOverrideRenderNode<Self> {
        ContextOverrideRenderNode(content: self, overrideContext: [.id: id as Any])
    }

    /// Creates a render node that overrides the animator of the content.
    /// - Parameter animator: An optional animator to be set for the content.
    /// - Returns: An `ContextOverrideRenderNode` with the overridden animator.
    public func animator(_ animator: Animator?) -> ContextOverrideRenderNode<Self> {
        ContextOverrideRenderNode(content: self, overrideContext: [.animator: animator as Any])
    }

    /// Creates a render node that overrides the reuse key of the content.
    /// - Parameter reuseKey: The String key to be set for the content.
    /// - Returns: A `ContextOverrideRenderNode` with the overridden reuse strategy.
    public func reuseKey(_ reuseKey: String?) -> ContextOverrideRenderNode<Self> {
        ContextOverrideRenderNode(content: self, overrideContext: [.reuseKey: reuseKey as Any])
    }
}
