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
public struct EnvironmentComponent<Value, Content: Component>: Component {
    let key: EnvironmentWritableValuesKey<Value>
    let value: Value
    let content: Content

    /// Initializes a new component with the specified key path, value, and content.
    /// - Parameters:
    ///   - keyPath: A key path to a specific writable value within the environment values.
    ///   - value: The value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value, content: Content) {
        self.key = .keyPath(keyPath)
        self.value = value
        self.content = content
    }

    /// Initializes a new component with the specified key type, value, and content.
    /// - Parameters:
    ///   - keyType: The type of the environment key to use for the value.
    ///   - value: The value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyType: any EnvironmentKey<Value>.Type, value: Value, content: Content) {
        self.key = .keyType(keyType)
        self.value = value
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> Content.R {
        EnvironmentValues.with(key: key, value: value) {
            content.layout(constraint)
        }
    }
}

/// A component that injects an environment value into the content.
/// The value is held weakly to avoid retain cycles.
///
/// Instead of creating it directly, use the ``ComponentBuilder/weakEnvironment(_:value:)`` method.
///
/// - Parameters:
///   - keyPath: A key path to a specific writable value within the environment values.
///   - value: The optional value to inject into the environment.
///   - content: The content component that will receive the environment value.
public struct WeakEnvironmentComponent<Value: AnyObject, Content: Component>: Component {
    let key: EnvironmentWritableValuesKey<Value?>
    weak var value: Value?
    let content: Content

    /// Initializes a new component with the specified key path, optional value, and content.
    /// The value is held weakly.
    /// - Parameters:
    ///   - keyPath: A key path to a specific writable value within the environment values.
    ///   - value: The optional value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyPath: WritableKeyPath<EnvironmentValues, Value?>, value: Value?, content: Content) {
        self.key = .keyPath(keyPath)
        self.value = value
        self.content = content
    }

    /// Initializes a new component with the specified key type, optional value, and content.
    /// The value is held weakly.
    /// - Parameters:
    ///   - keyType: The type of the environment key to use for the value.
    ///   - value: The optional value to inject into the environment.
    ///   - content: The content component that will receive the environment value.
    public init(keyType: any EnvironmentKey<Value?>.Type, value: Value?, content: Content) {
        self.key = .keyType(keyType)
        self.value = value
        self.content = content
    }

    /// Lays out the content within the current environment, injecting the value if it is not nil.
    /// - Parameter constraint: The constraints to use when laying out the content.
    /// - Returns: The laid out content.
    public func layout(_ constraint: Constraint) -> Content.R {
        if let value {
            EnvironmentValues.with(key: key, value: value) {
                content.layout(constraint)
            }
        } else {
            content.layout(constraint)
        }
    }
}
