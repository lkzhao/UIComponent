//  Created by Luke Zhao on 1/11/24.

import Foundation

/// A property wrapper that provides access to environment values.
/// It allows the injection of environment-specific values into your component tree.
///
/// A few benefit of using Environment:
/// - pass arbitrary data down the component tree without the need to explicitly pass it through each component.
/// - allow components to access environment values without knowing the details of the environment.
/// - allow components to be tested in isolation by providing a test environment.
///
/// ### Access an environment value
///
/// In your ``Component`` or ``ComponentBuilder``, use the ``Environment`` property wrapper to create a property that can access the environment value.
/// ```swift
/// @Environment(\.hostingView) var hostingView
/// ```
///
/// Inside ``Component/layout(_:)`` or ``ComponentBuilder/build()`` you can access the environment value directly.
/// ```swift
/// VStack {
///     // ...
/// }.inset { [weak hostingView] _ in
///     hostingView?.safeAreaInsets ?? .zero
/// }
/// ```
///
/// ### To create a custom environment value
///
/// Create a custom environment key with a default value provider:
/// ```swift
/// struct CurrentUserEnvironmentKey: EnvironmentKey {
///     static var defaultValue: User? {
///         nil
///     }
/// }
/// ```
///
/// Extend EnvironmentValues to provide a convenient access to the current user value
/// ```swift
/// extension EnvironmentValues {
///     var currentUser: User? {
///         get { self[CurrentUserEnvironmentKey.self] }
///         set { self[CurrentUserEnvironmentKey.self] = newValue }
///     }
/// }
/// ```
///
/// Extend Component to provide a convenient way to set the current user value
/// ```swift
/// extension Component {
///     func currentUser(_ user: User) -> EnvironmentComponent<User?, Self> {
///         environment(\.currentUser, value: user)
///     }
/// }
/// ```
///
/// Use the ``Environment`` property wrapper to access the environmentvalue
/// ```swift
/// struct ProfileComponent: ComponentBuilder {
///     // Use the `@Environment` property wrapper to access the environment value
///     @Environment(\.currentUser) var user: User?
///     func build() -> some Component {
///         VStack {
///             if let user {
///                 Text(user.name)
///             }
///         }
///     }
/// }
/// ```
///
/// From the parent component, you can set the environment value for its child component.
///
/// ```swift
/// ProfileComponent().currentUser(user)
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
