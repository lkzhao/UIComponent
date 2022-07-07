//  Created by Luke Zhao on 5/16/21.

import UIKit

/// # Background Component
///
/// Renders a single `child` with a `background` component below the child.
/// The size of the `child` is calculated first, then the size is applied to the `background` component.
/// The intrinsic size of the `background` component is ignored.
///
/// Alternative of the `Background` layout is the `Overlay` layout  which puts the primary `child` component
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
    let child: Component
    let background: Component

    public init(child: Component, background: Component) {
        self.child = child
        self.background = background
    }

    public func layout(_ constraint: Constraint) -> RenderNode {
        let childRenderNode = child.layout(constraint)
        let backgroundRenderNode = background.layout(Constraint(minSize: childRenderNode.size, maxSize: childRenderNode.size))
        return SlowRenderNode(size: childRenderNode.size, children: [backgroundRenderNode, childRenderNode], positions: [.zero, .zero])
    }
}
