extension Component {
    /// Applies the given component as a mask to the receiver.
    /// - Parameter component: The component used to build the masking view.
    /// - Returns: A component whose rendered view is masked by the provided component.
    public func maskBy<Mask: Component>(_ mask: Mask) -> some Component {
        MaskByComponent(content: self, mask: mask)
    }

    /// Applies a lazily built component as a mask to the receiver.
    /// - Parameter maskBuilder: Builder invoked during layout to create the masking component.
    /// - Returns: A component whose rendered view is masked by the provided component.
    public func maskBy<Mask: Component>(_ maskBuilder: @escaping () -> Mask) -> some Component {
        MaskByComponent(content: self, mask: maskBuilder())
    }

    /// Uses the receiver to mask the provided component.
    /// - Parameter component: The component to be masked by the receiver.
    /// - Returns: A component masking the provided component with `self`.
    public func masking<Content: Component>(_ content: Content) -> some Component {
        MaskComponent(content: content, mask: self)
    }

    /// Uses the receiver to mask a lazily built component.
    /// - Parameter componentBuilder: Builder invoked during layout to create the component being masked.
    /// - Returns: A component masking the lazily created component with `self`.
    public func masking<Content: Component>(_ contentBuilder: @escaping () -> Content) -> some Component {
        MaskComponent(content: contentBuilder(), mask: self)
    }
}

/// A component that renders content using another component as its mask.
public struct MaskComponent<Content: Component, Mask: Component>: Component {
    public let content: Content
    public let mask: Mask

    public init(content: Content, mask: Mask) {
        self.content = content
        self.mask = mask
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let maskRenderNode = mask.layout(constraint)
        return content
            .update { view in
                let maskView: ComponentView
                if let existingMask = view.mask as? ComponentView {
                    maskView = existingMask
                } else {
                    maskView = ComponentView()
                    view.mask = maskView
                }
                maskView.frame = CGRect(origin: .zero, size: maskRenderNode.size)
                maskView.componentEngine.reloadWithExisting(component: mask, renderNode: maskRenderNode)
            }
            .layout(.init(tightSize: maskRenderNode.size))
    }
}

/// A component that renders content and applies the receiver as a mask to it.
public struct MaskByComponent<Content: Component, Mask: Component>: Component {
    public let content: Content
    public let mask: Mask

    public init(content: Content, mask: Mask) {
        self.content = content
        self.mask = mask
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let contentRenderNode = content.layout(constraint)
        return contentRenderNode
            .update { view in
                let maskView: ComponentView
                if let existingMask = view.mask as? ComponentView {
                    maskView = existingMask
                } else {
                    maskView = ComponentView()
                    view.mask = maskView
                }
                maskView.frame = CGRect(origin: .zero, size: contentRenderNode.size)
                maskView.componentEngine.component = mask.size(contentRenderNode.size)
            }
    }
}
