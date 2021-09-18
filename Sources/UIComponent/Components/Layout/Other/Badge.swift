//  Created by y H on 2021/7/25.

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
/// someComponent.badge(someOtherComponent, offset: CGVector(dx: 8, dy: -8))
/// ```
/// or
/// ```swift
/// someComponent.badge(offset: CGVector(dx: 8, dy: -8)) {
///   someOtherComponent
/// }
/// ```
///
/// Checkout the `ComplexLayoutViewController.swift` for other examples.
public struct Badge: Component {
  let child: Component
  let overlay: Component
  let verticalAlignment: CrossAxisAlignment
  let horizontalAlignment: CrossAxisAlignment
  let offset: CGVector

  public func layout(_ constraint: Constraint) -> RenderNode {
    let childRenderNode = child.layout(constraint)
    let badgeRenderNode = overlay.layout(
      Constraint(
        minSize: CGSize(
          width: horizontalAlignment == .stretch ? childRenderNode.size.width : -.infinity,
          height: verticalAlignment == .stretch ? childRenderNode.size.height : -.infinity
        ),
        maxSize: childRenderNode.size
      )
    )
    let beagePosition: (x: CGFloat, y: CGFloat)
    switch horizontalAlignment {
    case .start:
      beagePosition.x = 0
    case .end:
      beagePosition.x = (childRenderNode.size.width - badgeRenderNode.size.width)
    case .center:
      beagePosition.x = (childRenderNode.size.width / 2 - badgeRenderNode.size.width / 2)
    case .stretch:
      beagePosition.x = 0
    }
    switch verticalAlignment {
    case .start:
      beagePosition.y = 0
    case .end:
      beagePosition.y = (childRenderNode.size.height - badgeRenderNode.size.height)
    case .center:
      beagePosition.y = (childRenderNode.size.height / 2 - badgeRenderNode.size.height / 2)
    case .stretch:
      beagePosition.y = 0
    }
    let finallyBadgePosition = CGPoint(x: beagePosition.x, y: beagePosition.y) + offset

    return SlowRenderNode(size: childRenderNode.size, children: [childRenderNode, badgeRenderNode], positions: [.zero, finallyBadgePosition])
  }
}
