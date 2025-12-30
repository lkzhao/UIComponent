//  Created by Luke Zhao on 5/16/21.

/// Renders a single `content` component with a `background` component below the content.
/// The size of the `content` is calculated first, then the size is applied to the `background` component.
/// The intrinsic size of the `background` component is ignored.
///
/// Alternative of the `Background` layout is the `Overlay` layout  which puts the primary `content` component
/// behind the `overlay` component.
///
/// Instead of using it directly, you can easily create Background layout by using the `.background` modifier.
/// ```swift
/// someComponent.background(someOtherComponent)
/// ```
/// or
/// ```swift
/// someComponent.background {
///   someOtherComponent
/// }
/// ```
public struct Background: Component {
    /// The component that is being rendered.
    public let content: any Component
    /// The component that is used as a background.
    public let background: any Component

    /// Initializes a new `Background` component with a given `content` and `background`.
    /// - Parameters:
    ///   - content: The component to be rendered on top of the `background`.
    ///   - background: The component to be used as a background, rendered below the `content`.
    public init(content: any Component, background: any Component) {
        self.content = content
        self.background = background
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let contentRenderNode = content.layout(constraint)
        let backgroundRenderNode = background.layout(Constraint(minSize: contentRenderNode.size, maxSize: contentRenderNode.size))
        return SlowRenderNode(size: contentRenderNode.size, children: [backgroundRenderNode, contentRenderNode], positions: [.zero, .zero])
    }
}
