//  Created by Luke Zhao on 6/12/21.

/// Renders a single `content` component with a `overlay` component on top.
/// The size of the `content` is calculated first, then the size is applied to the `overlay` component.
/// The intrinsic size of the `overlay` component is ignored.
///
/// Alternative of the `Overlay` layout is the `Background` layout  which puts the primary `content` component
/// on top the `background` component.
///
/// Instead of using it directly, you can easily create` Overlay` layout by using the ``Component/overlay(_:)-8hkmt`` modifier.
/// ```swift
/// someComponent.overlay(someOtherComponent)
/// ```
/// or
/// ```swift
/// someComponent.overlay {
///   someOtherComponent
/// }
/// ```
public struct Overlay: Component {
    /// The component that is being rendered beneath the overlay.
    public let content: any Component
    /// The component that is rendered on top of the content.
    public let overlay: any Component

    /// Initializes a new overlay with the specified content and overlay components.
    /// - Parameters:
    ///   - content: The component to be rendered beneath the overlay.
    ///   - overlay: The component to be rendered on top of the content.
    public init(content: any Component, overlay: any Component) {
        self.content = content
        self.overlay = overlay
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let contentRenderNode = content.layout(constraint)
        let overlayRenderNode = overlay.layout(Constraint(minSize: contentRenderNode.size, maxSize: contentRenderNode.size))
        return SlowRenderNode(size: contentRenderNode.size, children: [contentRenderNode, overlayRenderNode], positions: [.zero, .zero])
    }
}
