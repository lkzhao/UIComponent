//  Created by Luke Zhao on 8/23/20.

import UIKit

/// # Flexible Component
///
/// Wraps a child component and marking it for the flex layouts to treat it as flexible.
///
/// Instead of using it directly, you can use `.flex()` modifier on any component to mark it as flexible.
///
/// Checkout the `FlexLayoutViewController.swift` for more examples.
public struct Flexible: Component {
    public let flexGrow: CGFloat
    public let flexShrink: CGFloat
    public let alignSelf: CrossAxisAlignment?
    public let child: Component
    public func layout(_ constraint: Constraint) -> any RenderNode {
        child.layout(constraint)
    }
}
