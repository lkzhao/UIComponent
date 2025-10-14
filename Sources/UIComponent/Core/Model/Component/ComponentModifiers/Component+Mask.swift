import UIKit

extension Component {
    /// Applies the given component as a mask to the receiver.
    /// - Parameter component: The component used to build the masking view.
    /// - Returns: A component whose rendered view is masked by the provided component.
    public func maskBy(_ component: any Component) -> some Component {
        MaskComponent(component: self, mask: component)
    }

    /// Applies a lazily built component as a mask to the receiver.
    /// - Parameter componentBuilder: Builder invoked during layout to create the masking component.
    /// - Returns: A component whose rendered view is masked by the provided component.
    public func maskBy(_ componentBuilder: @escaping () -> any Component) -> some Component {
        MaskComponent(component: self, mask: componentBuilder())
    }

    /// Uses the receiver to mask the provided component.
    /// - Parameter component: The component to be masked by the receiver.
    /// - Returns: A component masking the provided component with `self`.
    public func masking(_ component: any Component) -> some Component {
        MaskComponent(component: AnyComponent(content: component), mask: self)
    }

    /// Uses the receiver to mask a lazily built component.
    /// - Parameter componentBuilder: Builder invoked during layout to create the component being masked.
    /// - Returns: A component masking the lazily created component with `self`.
    public func masking(_ componentBuilder: @escaping () -> any Component) -> some Component {
        MaskComponent(component: AnyComponent(content: componentBuilder()), mask: self)
    }
}

/// A component that renders content using another component as its mask.
public struct MaskComponent<Content: Component>: Component {
    public let component: Content
    public let mask: any Component

    public init(component: Content, mask: any Component) {
        self.component = component
        self.mask = mask
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let maskRenderNode = mask.layout(constraint)
        return component
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
