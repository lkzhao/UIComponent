/// A component produced by the ``Component/id(_:)`` modifier
public struct IDComponent<Content: Component>: Component {
    public let content: Content
    public let idValue: String?

    public init(content: Content, idValue: String?) {
        self.content = content
        self.idValue = idValue
    }

    public func layout(_ constraint: Constraint) -> ContextOverrideRenderNode<Content.R> {
        let renderNode = LayoutIdentityContext.withExplicitID(idValue) {
            content.layout(constraint)
        }
        return renderNode.id(idValue)
    }
}

/// A component produced by the ``Component/animator(_:)`` modifier
public typealias AnimatorComponent<Content: Component> = ModifierComponent<Content, ContextOverrideRenderNode<Content.R>>

/// A component produced by the ``Component/reuseKey(_:)`` modifier
public typealias ReuseKeyComponent<Content: Component> = ModifierComponent<Content, ContextOverrideRenderNode<Content.R>>

extension Component {
    /// Assigns an identifier to the component.
    /// - Parameter id: An optional string that uniquely identifies the component.
    /// - Returns: An `IDComponent` that represents the modified component with an assigned ID.
    public func id(_ id: String?) -> IDComponent<Self> {
        IDComponent(content: self, idValue: id)
    }

    /// Associates an animator with the component.
    ///
    /// There is also the ``Component/animateInsert(_:)``, ``Component/animateUpdate(passthrough:_:)``, and ``Component/animateDelete(_:)``
    /// modifiers that can be used to override insertions, updates, and deletions animation separately.
    ///
    /// - Parameter animator: An optional `Animator` object that defines how the component's updates are animated.
    /// - Returns: An `AnimatorComponent` that represents the modified component with an associated animator.
    public func animator(_ animator: Animator?) -> AnimatorComponent<Self> {
        ModifierComponent(content: self) {
            $0.animator(animator)
        }
    }

    /// Sets the reuse key for the component.
    /// - Parameter reuseKey: A String key value for reusing the view for the component.
    /// - Returns: A `ReuseKeyComponent` that represents the modified component with a specified reuse strategy.
    public func reuseKey(_ reuseKey: String) -> ReuseKeyComponent<Self> {
        ModifierComponent(content: self) {
            $0.reuseKey(reuseKey)
        }
    }
}
