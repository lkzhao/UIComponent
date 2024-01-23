//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/20/24.
//

import Foundation

/// `EnvironmentValues` is a container for environment-specific values.
/// It provides a type-safe interface to access values keyed by custom types conforming to `EnvironmentKey`.
///
/// Checkout ``Environment`` for more information.
public struct EnvironmentValues {
    /// A dictionary to hold environment values with their associated key type's `ObjectIdentifier`.
    private var values: [ObjectIdentifier: Any] = [:]

    /// Accesses the environment value associated with a custom key.
    /// - Parameter keyType: The key type for the value to access.
    /// - Returns: The value associated with the key, or the key's default value if it's not present.
    public subscript<Value>(keyType: any EnvironmentKey<Value>.Type) -> Value {
        get {
            values[ObjectIdentifier(keyType)] as? Value ?? keyType.defaultValue
        }
        set {
            values[ObjectIdentifier(keyType)] = newValue
        }
    }

    /// A stack to keep track of the current environment values for nested environment changes.
    private static var stack: [EnvironmentValues] {
        get {
            Thread.current.threadDictionary["currentEnvironmentValuesStack"] as? [EnvironmentValues] ?? []
        }
        set {
            Thread.current.threadDictionary["currentEnvironmentValuesStack"] = newValue
        }
    }

    /// The current environment values.
    public internal(set) static var current: EnvironmentValues {
        get {
            Thread.current.threadDictionary["currentEnvironmentValues"] as? EnvironmentValues ?? EnvironmentValues()
        }
        set {
            Thread.current.threadDictionary["currentEnvironmentValues"] = newValue
        }
    }

    /// Saves the current environment values onto the stack.
    internal static func saveCurrentValues() {
        stack.append(current)
    }

    /// Restores the last environment values from the stack.
    internal static func restoreCurrentValues() {
        guard let last = stack.popLast() else {
            assertionFailure("Inbalanced environment save/restore")
            return
        }
        current = last
    }

    /// Executes a given closure with a temporarily modified environment.
    /// - Parameters:
    ///   - key: The key that identifies the value to be temporarily set.
    ///   - value: The temporary value to set for the given key.
    ///   - accessor: A closure to execute with the modified environment.
    /// - Throws: Rethrows any errors thrown by the `accessor` closure.
    /// - Returns: The result of the `accessor` closure.
    internal static func with<Value, Result>(key: EnvironmentWritableValuesKey<Value>, value: Value, accessor: () throws -> Result) rethrows -> Result {
        saveCurrentValues()
        switch key {
        case let .keyType(keyType):
            current[keyType] = value
        case let .keyPath(keyPath):
            current[keyPath: keyPath] = value
        }
        let result = try accessor()
        restoreCurrentValues()
        return result
    }

    /// Executes a given closure with a temporarily modified environment for a specific key type.
    /// - Parameters:
    ///   - keyType: The type of the key for the value to access.
    ///   - value: The temporary value to set for the given key type.
    ///   - accessor: A closure to execute with the modified environment.
    /// - Throws: Rethrows any errors thrown by the `accessor` closure.
    /// - Returns: The result of the `accessor` closure.
    public static func with<Value, Result>(_ keyType: any EnvironmentKey<Value>.Type, value: Value, accessor: () throws -> Result) rethrows -> Result {
        try with(key: .keyType(keyType), value: value, accessor: accessor)
    }

    /// Executes a given closure with a temporarily modified environment for a specific key path.
    /// - Parameters:
    ///   - keyPath: The key path of the value to modify.
    ///   - value: The temporary value to set for the given key path.
    ///   - accessor: A closure to execute with the modified environment.
    /// - Throws: Rethrows any errors thrown by the `accessor` closure.
    /// - Returns: The result of the `accessor` closure.
    public static func with<Value, Result>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value, accessor: () throws -> Result) rethrows -> Result {
        try with(key: .keyPath(keyPath), value: value, accessor: accessor)
    }
}

/// An enumeration that defines keys for accessing values in the environment.
/// This is used internally for accessing environment values. Both type can be used to access the same value.
/// - `keyPath`: A key path to a specific value within `EnvironmentValues`.
/// - `keyType`: An EnvironmentKey type.
internal enum EnvironmentValuesKey<Value> {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case keyType(any EnvironmentKey<Value>.Type)
}

/// An enumeration that defines keys for accessing values in the environment.
/// This is used internally for accessing environment values. Both type can be used to access the same value.
/// - `keyPath`: A writable key path to a specific value within `EnvironmentValues`.
/// - `keyType`: An EnvironmentKey type.
internal enum EnvironmentWritableValuesKey<Value> {
    case keyPath(WritableKeyPath<EnvironmentValues, Value>)
    case keyType(any EnvironmentKey<Value>.Type)
}
