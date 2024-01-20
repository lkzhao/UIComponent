//  Created by Luke Zhao on 1/11/24.

import Foundation

/// A property wrapper that provides access to environment values.
/// It allows the injection of environment-specific values into your component tree.
///
/// ```swift
/// // Access the current component view within a component
/// @Environment(\.currentComponentView) var currentComponentView
/// ```
///
/// ### To create a custom environment value
/// ```swift
/// // Create a custom environment key with a default value provider
/// struct CurrentUserEnvironmentKey: EnvironmentKey {
///     static var defaultValue: User? {
///         nil
///     }
/// }
///
/// // Extend EnvironmentValues to provide a convenient access to the current user value
/// extension EnvironmentValues {
///     var currentUser: User? {
///         get { self[CurrentUserEnvironmentKey.self] }
///         set { self[CurrentUserEnvironmentKey.self] = newValue }
///     }
/// }
///
/// // Extend Component to provide a convenient way to set the current user value
/// extension Component {
///     func currentUser(_ user: User) -> EnvironmentComponent<User?, Self> {
///         environment(\.currentUser, value: user)
///     }
/// }
///
/// struct ProfileComponent: ComponentBuilder {
///     // Use the `@Environment` property wrapper to access the current user value
///     @Environment(\.currentUser)
///     var user: User?
///
///     func build() -> some Component {
///         VStack {
///             // access the environment value inside ``ComponetBuilder/build()`` or ``Compoent/layout(_:)``.
///             if let user {
///                 Text(user.name)
///             }
///         }
///     }
/// }
/// ```
@propertyWrapper public struct Environment<Value> {
    /// The key used to access the environment value.
    let key: EnvironmentValuesKey<Value>

    /// Initializes the environment property wrapper with a key path.
    /// - Parameter keyPath: A key path to the specific environment value.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.key = .keyPath(keyPath)
    }

    /// Initializes the environment property wrapper with a key type.
    /// - Parameter keyType: A type conforming to `EnvironmentKey` protocol.
    public init(_ keyType: any EnvironmentKey<Value>.Type) {
        self.key = .keyType(keyType)
    }

    /// The current value of the environment property.
    public var wrappedValue: Value {
        switch key {
        case let .keyPath(keyPath):
            return EnvironmentValues.current[keyPath: keyPath]
        case let .keyType(keyType):
            return EnvironmentValues.current[keyType]
        }
    }
}
