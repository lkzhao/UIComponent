//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/20/24.
//

import Foundation

/// A component that injects an environment value into the content.
///
/// Instead of creating it directly, use the ``ComponentBuilder/environment(_:value:)`` method.
///
/// - Parameters:
///   - keyPath: A key path to a specific writable value within the environment values.
///   - value: The value to inject into the environment.
///   - content: The content component that will receive the environment value.
public struct EnvironmentComponent<Value, Content: Component>: ComponentWrapper {
    public let values: EnvironmentValues
    public let content: Content

    /// Initializes a new component with the specified key path, value, and content.
    /// - Parameters:
    ///   - keyPath: A key path to a specific writable value within the environment values.
    ///   - value: The value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value, content: Content) {
        var values = EnvironmentValues()
        values[keyPath: keyPath] = value
        self.values = values
        self.content = content
    }

    /// Initializes a new component with the specified key type, value, and content.
    /// - Parameters:
    ///   - keyType: The type of the environment key to use for the value.
    ///   - value: The value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyType: any EnvironmentKey<Value>.Type, value: Value, content: Content) {
        var values = EnvironmentValues()
        values[keyType] = value
        self.values = values
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> Content.R {
        EnvironmentValues.with(values: values) {
            content.layout(constraint)
        }
    }
}

