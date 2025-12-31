//  Created by Luke Zhao on 6/21/23.

/// A type-erased `Component`
///
/// Useful for:
/// * storing a collection of components of different types.
/// * returning a component of different type.
///
/// Instead of creating ``AnyComponent`` directly, It is easier to use the ``Component/eraseToAnyComponent()`` modifier to create a type-erased component.
/// ```swift
/// SomeComponent().eraseToAnyComponent()
/// ```
public struct AnyComponent: Component {
    /// The underlying component being type-erased.
    public let content: any Component

    /// Initializes a new type-erased component with the provided component.
    /// - Parameter content: The component to be type-erased.
    public init(content: any Component) {
        self.content = content
    }
    
    /// Lays out the component within the given constraints and returns a type-erased render node.
    /// - Parameter constraint: The constraints to use for laying out the component.
    /// - Returns: A type-erased `AnyRenderNode` representing the layout of the component.
    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        content.layout(constraint).eraseToAnyRenderNode()
    }
}

/// A type-erased `Component` that is specialized for a specific `PlatformView` subclass.
///
/// Instead of creating ``AnyComponentOfView`` directly, It is easier to use the ``Component/eraseToAnyComponentOfView()`` modifier to create a type-erased component.
/// ```swift
/// SomeComponent().eraseToAnyComponentOfView()
/// ```
public struct AnyComponentOfView<View: PlatformView>: Component {
    private let _layout: (Constraint) -> AnyRenderNodeOfView<View>

    /// Initializes a new type-erased component with the provided content component.
    /// - Parameter content: The content component to be type-erased, which must produce a `View` of the specified type.
    public init<Content: Component>(content: Content) where Content.R.View == View {
        self._layout = { constraint in
            AnyRenderNodeOfView(content.layout(constraint))
        }
    }
    
    /// Lays out the content component within the given constraints and returns a type-erased render node specialized for the `View` type.
    /// - Parameter constraint: The constraints to use for laying out the content component.
    /// - Returns: A type-erased `AnyRenderNodeOfView` representing the layout of the content component.
    public func layout(_ constraint: Constraint) -> AnyRenderNodeOfView<View> {
        _layout(constraint)
    }
}
