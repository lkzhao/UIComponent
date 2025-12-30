//  Created by Luke Zhao on 6/25/23.

/// A `ModifierComponent` is a generic structure that represents a component that can be modified.
/// It takes a `Component` and applies a modification to produce a `RenderNode`.
///
/// - Parameters:
///   - Content: The type of the original component that is being modified.
///   - Result: The type of the result after the modification.
public struct ModifierComponent<Content: Component, Result: RenderNode>: Component where Content.R.View == Result.View {
    /// The original content component.
    public let content: Content
    
    /// The modifier closure that takes the original component's `RenderNode` and returns a modified `RenderNode`.
    public let modifier: (Content.R) -> Result

    /// Initializes a new `ModifierComponent` with the provided content and modifier.
    ///
    /// - Parameters:
    ///   - content: The original content component.
    ///   - modifier: A closure that modifies the content's `RenderNode`.
    public init(content: Content, modifier: @escaping (Content.R) -> Result) {
        self.content = content
        self.modifier = modifier
    }

    /// Lays out the content within the given constraints and applies the modifier to the result.
    ///
    /// - Parameter constraint: The constraints to use when laying out the content.
    /// - Returns: A modified `RenderNode` after applying the modifier to the content's layout result.
    public func layout(_ constraint: Constraint) -> Result {
        modifier(content.layout(constraint))
    }
}
