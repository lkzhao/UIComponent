//  Created by Luke Zhao on 6/12/21.

import Foundation

/// # Overlay Component
///
/// Renders a single `child` component with a `overlay` component on top.
/// The size of the `child` is calculated first, then the size is applied to the `overlay` component.
/// The intrinsic size of the `overlay` component is ignored.
///
/// Alternative of the `Overlay` layout is the `Background` layout  which puts the primary `child` component
/// on top the `background` component.
///
/// Instead of using it directly, you can easily create` Overlay` layout by using the `.overlay` modifier.
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
    let child: Component
    let overlay: Component

    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        let childRenderNode = child.layout(constraint)
        let overlayRenderNode = overlay.layout(Constraint(minSize: childRenderNode.size, maxSize: childRenderNode.size))
        return SlowRenderNode(size: childRenderNode.size, children: [childRenderNode, overlayRenderNode], positions: [.zero, .zero])
    }
}
