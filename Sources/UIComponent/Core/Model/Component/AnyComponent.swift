//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/21/23.
//

import UIKit

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
    public let erasing: any Component
    
    /// Initializes a new type-erased component with the provided component.
    /// - Parameter erasing: The component to be type-erased.
    public init(_ erasing: any Component) {
        self.erasing = erasing
    }
    
    /// Lays out the component within the given constraints and returns a type-erased render node.
    /// - Parameter constraint: The constraints to use for laying out the component.
    /// - Returns: A type-erased `AnyRenderNode` representing the layout of the component.
    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        erasing.layout(constraint).eraseToAnyRenderNode()
    }
}

/// A type-erased `Component` that is specialized for a specific `UIView` subclass.
///
/// Instead of creating ``AnyComponentOfView`` directly, It is easier to use the ``Component/eraseToAnyComponentOfView()`` modifier to create a type-erased component.
/// ```swift
/// SomeComponent().eraseToAnyComponentOfView()
/// ```
public struct AnyComponentOfView<View: UIView>: Component {
    /// The child component being type-erased.
    public let child: any Component
    
    /// Initializes a new type-erased component with the provided child component.
    /// - Parameter child: The child component to be type-erased, which must produce a `View` of the specified type.
    public init<Child: Component>(child: Child) where Child.R.View == View {
        self.child = child
    }
    
    /// Lays out the child component within the given constraints and returns a type-erased render node specialized for the `View` type.
    /// - Parameter constraint: The constraints to use for laying out the child component.
    /// - Returns: A type-erased `AnyRenderNodeOfView` representing the layout of the child component.
    public func layout(_ constraint: Constraint) -> AnyRenderNodeOfView<View> {
        AnyRenderNodeOfView(child.layout(constraint))
    }
}
