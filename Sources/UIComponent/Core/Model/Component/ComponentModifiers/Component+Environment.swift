import UIKit

// MARK: - Environment modifiers
public extension Component {
    /// Applies an environment value to the component for the given key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific environment value.
    ///   - value: The value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyPath: keyPath, value: value, content: self)
    }

    /// Applies an environment value to the component for the given environment key type.
    /// - Parameters:
    ///   - keyType: The type of the environment key.
    ///   - value: The value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyType: any EnvironmentKey<Value>.Type, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyType: keyType, value: value, content: self)
    }

    /// Applies an environment value to the component for the given key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific environment value.
    ///   - valueBuilder: A closure to be called to generate the value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, valueBuilder: () -> Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyPath: keyPath, value: valueBuilder(), content: self)
    }

    /// Applies an environment value to the component for the given environment key type.
    /// - Parameters:
    ///   - keyType: The type of the environment key.
    ///   - valueBuilder: A closure to be called to generate the value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyType: any EnvironmentKey<Value>.Type, valueBuilder: () -> Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyType: keyType, value: valueBuilder(), content: self)
    }
}
