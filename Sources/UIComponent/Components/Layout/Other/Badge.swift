//  Created by y H on 2021/7/25.

@_implementationOnly import BaseToolbox
import UIKit

/// # Badge Component
///
/// Renders a single child component with a badge (overlay) component on top.
/// The `Badge` component is similar to the `Overlay` component. The differences between `Badge` and `Overlay` are the following:
/// 1. `Badge` calculates the `badge` size based on its own content.
/// 2. `Badge` allows you to specify a `verticalAlignment` and a `horizontalAlignment` to control the `badge` position, similar to `ZStack`.
/// 3. `Badge` allows you to specify an `offset` for the `badge` component.
///
/// Instead of using it directly, you can easily create a` Badge` component by using the `.badge` modifier.
/// ```swift
/// someComponent.badge(someOtherComponent, offset: CGPoint(x: 8, y: -8))
/// ```
/// or
/// ```swift
/// someComponent.badge(offset: CGPoint(x: 8, y: -8)) {
///   someOtherComponent
/// }
/// ```
///
/// Checkout the `ComplexLayoutViewController.swift` for other examples.
public struct Badge: Component {
    public enum Alignment: CaseIterable {
        case start, end, center, stretch, before, after
    }
    let child: Component
    let overlay: Component
    let verticalAlignment: Alignment
    let horizontalAlignment: Alignment
    let offset: CGPoint

    public func layout(_ constraint: Constraint) -> RenderNode {
        let childRenderNode = child.layout(constraint)
        let badgeRenderNode = overlay.layout(
            Constraint(
                minSize: CGSize(
                    width: horizontalAlignment == .stretch ? childRenderNode.size.width : -.infinity,
                    height: verticalAlignment == .stretch ? childRenderNode.size.height : -.infinity
                ),
                maxSize: CGSize(
                    width: horizontalAlignment == .stretch ? childRenderNode.size.width : .infinity,
                    height: verticalAlignment == .stretch ? childRenderNode.size.height : .infinity
                )
            )
        )
        let badgePosition: (x: CGFloat, y: CGFloat)
        switch horizontalAlignment {
        case .start:
            badgePosition.x = 0
        case .end:
            badgePosition.x = (childRenderNode.size.width - badgeRenderNode.size.width)
        case .center:
            badgePosition.x = (childRenderNode.size.width / 2 - badgeRenderNode.size.width / 2)
        case .stretch:
            badgePosition.x = 0
        case .before:
            badgePosition.x = -badgeRenderNode.size.width
        case .after:
            badgePosition.x = childRenderNode.size.width
        }
        switch verticalAlignment {
        case .start:
            badgePosition.y = 0
        case .end:
            badgePosition.y = (childRenderNode.size.height - badgeRenderNode.size.height)
        case .center:
            badgePosition.y = (childRenderNode.size.height / 2 - badgeRenderNode.size.height / 2)
        case .stretch:
            badgePosition.y = 0
        case .before:
            badgePosition.y = -badgeRenderNode.size.height
        case .after:
            badgePosition.y = childRenderNode.size.height
        }
        let finallyBadgePosition = CGPoint(x: badgePosition.x + offset.x, y: badgePosition.y + offset.y)

        return AlwaysRenderNode(size: childRenderNode.size, children: [childRenderNode, badgeRenderNode], positions: [.zero, finallyBadgePosition])
    }
}
