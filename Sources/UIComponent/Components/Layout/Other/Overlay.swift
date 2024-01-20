//  Created by Luke Zhao on 6/12/21.

import Foundation

/// Renders a single `child` component with a `overlay` component on top.
/// The size of the `child` is calculated first, then the size is applied to the `overlay` component.
/// The intrinsic size of the `overlay` component is ignored.
///
/// Alternative of the `Overlay` layout is the `Background` layout  which puts the primary `child` component
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
    public let child: any Component
    /// The component that is rendered on top of the child.
    public let overlay: any Component

    /// Initializes a new overlay with the specified child and overlay components.
    /// - Parameters:
    ///   - child: The component to be rendered beneath the overlay.
    ///   - overlay: The component to be rendered on top of the child.
    public init(child: any Component, overlay: any Component) {
        self.child = child
        self.overlay = overlay
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let childRenderNode = child.layout(constraint)
        let overlayRenderNode = overlay.layout(Constraint(minSize: childRenderNode.size, maxSize: childRenderNode.size))
        return SlowRenderNode(size: childRenderNode.size, children: [childRenderNode, overlayRenderNode], positions: [.zero, .zero])
    }
}
