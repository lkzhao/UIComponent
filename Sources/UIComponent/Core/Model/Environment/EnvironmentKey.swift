//  Created by Luke Zhao on 1/20/24.

/// A protocol that defines a specific environment key.
///
/// See ``Environment`` on how to create a custom ``EnvironmentKey``.
public protocol EnvironmentKey<Value> {
    associatedtype Value

    /// The default value for the environment key.
    static var defaultValue: Value { get }

    /// Whether the value should be weakly stored.
    static var isWeak: Bool { get }
}

extension EnvironmentKey {
    public static var isWeak: Bool {
        false
    }
}
