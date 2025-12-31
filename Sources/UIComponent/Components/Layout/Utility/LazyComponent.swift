//  Created by Luke Zhao on 5/12/25.

/// A component that defers the layout and rendering of its content until needed.
///
/// `LazyComponent` is useful for optimizing performance by delaying the creation and layout of its content
/// until it is actually required. This is particularly beneficial for expensive or rarely used components.
///
/// Note: `LazyComponent` does not support context values.
/// If you need to provide context values, do it outside of the LazyComponent.
///
/// - Parameters:
///   - Content: The type of the content component to be lazily rendered.
public struct LazyComponent<Content: Component>: Component {
    /// The content component to be lazily rendered.
    public let component: Content
    /// A closure that determines the size of the component based on the given constraint.
    public let sizeProvider: (Constraint) -> CGSize

    /// Initializes a `LazyComponent` with a content component and a custom size getter closure.
    /// - Parameters:
    ///   - component: The content component to be lazily rendered.
    ///   - sizeProvider: A closure that returns the size for the given constraint.
    public init(component: Content, sizeProvider: @escaping (Constraint) -> CGSize) {
        self.component = component
        self.sizeProvider = sizeProvider
    }

    /// Initializes a `LazyComponent` with a content component and a fixed size.
    /// - Parameters:
    ///   - component: The content component to be lazily rendered.
    ///   - size: The fixed size to use for the component.
    public init(component: Content, size: CGSize) {
        self.init(component: component) { _ in size }
    }

    /// Lays out the component using the provided constraint, returning a `LazyRenderNode`.
    /// - Parameter constraint: The constraint to use for layout.
    /// - Returns: A `LazyRenderNode` that wraps the content component and defers its layout.
    public func layout(_ constraint: Constraint) -> LazyRenderNode<Content> {
        LazyRenderNode(component: component, environmentValues: EnvironmentValues.current, size: sizeProvider(constraint))
    }
}

/// A render node wrapper that defers the layout and rendering of its content until accessed.
///
/// `LazyRenderNode` stores the component, its environment values, and the size. The actual layout
/// of the content is performed only when the `content` property is accessed for the first time.
/// This allows for lazy evaluation and can improve performance for expensive layouts.
///
/// - Parameters:
///   - Content: The type of the content component to be lazily rendered.
public class LazyRenderNode<Content: Component>: RenderNodeWrapper {
    /// The content component to be lazily rendered.
    public let component: Content

    /// The lazily created render node for the content component.
    private var _content: Content.R?

    /// The render node for the content component, created on first access.
    public var content: Content.R {
        if _content == nil {
            EnvironmentValues.saveCurrentValues()
            defer { EnvironmentValues.restoreCurrentValues() }
            EnvironmentValues.current = environmentValues
            _content = component.layout(.init(tightSize: size))
        }
        return _content!
    }

    /// Indicates whether the content has been laid out.
    public var didLayout: Bool {
        _content != nil
    }

    /// The size to use for the content component.
    public let size: CGSize

    /// The environment values to use when laying out the content.
    public let environmentValues: EnvironmentValues

    /// Initializes a `LazyRenderNode` with the given component, environment values, and size.
    /// - Parameters:
    ///   - component: The content component to be lazily rendered.
    ///   - environmentValues: The environment values to use for layout.
    ///   - size: The size to use for the content component.
    public init(component: Content, environmentValues: EnvironmentValues, size: CGSize) {
        self.component = component
        self.environmentValues = environmentValues
        self.size = size
    }

    /// Note: LazyRenderNode does not support context values.
    /// If you need to provide context values, do it outside of the LazyComponent.
    /// This method always returns nil.
    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        nil
    }
}
