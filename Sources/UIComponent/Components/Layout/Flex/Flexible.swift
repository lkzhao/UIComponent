//  Created by Luke Zhao on 8/23/20.

import UIKit

/// Protocol defining the flexibility properties of a component.
/// It includes properties for growing and shrinking the component
/// relative to its siblings in a flex layout, as well as alignment.
public protocol AnyFlexible {
    /// The factor that determines how much a component will grow relative to its siblings.
    var flexGrow: CGFloat { get }
    /// The factor that determines how much a component will shrink relative to its siblings.
    var flexShrink: CGFloat { get }
    /// The alignment of this component on the cross axis, if different from the default.
    var alignSelf: CrossAxisAlignment? { get }
}

/// Wraps a content component and provide flex layout properties to the parent.
///
/// Instead of using it directly, you can use `.flex()` modifier on any component to mark it as flexible.
///
/// Checkout the `FlexLayoutViewController.swift` for more examples.
public struct Flexible<Content: Component>: ComponentWrapper, AnyFlexible {
    /// The factor that determines how much this component will grow relative to its siblings.
    public let flexGrow: CGFloat
    /// The factor that determines how much this component will shrink relative to its siblings.
    public let flexShrink: CGFloat
    /// The alignment of this component on the cross axis, if different from the default.
    public let alignSelf: CrossAxisAlignment?
    /// The content component that this `Flexible` component wraps.
    public let content: Content
    
    /// Lays out the content component within the given constraints and wraps it in a `FlexibleRenderNode`.
    /// - Parameter constraint: The constraints to use when laying out the content component.
    /// - Returns: A `FlexibleRenderNode` containing the laid out content component.
    public func layout(_ constraint: Constraint) -> FlexibleRenderNode<Content.R> {
        FlexibleRenderNode(content: content.layout(constraint))
    }
}

/// A render node that wraps a content node, used by `Flexible`.
public struct FlexibleRenderNode<Content: RenderNode>: RenderNodeWrapper {
    /// The content node that this render node wraps.
    public let content: Content
}
