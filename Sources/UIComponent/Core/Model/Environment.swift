//  Created by Luke Zhao on 1/11/24.

import Foundation

internal class EnvironmentManager {
    internal static let shared = EnvironmentManager()

    private struct EnvironmentValues {
        let values: [ObjectIdentifier: Any]
        init() {
            values = [:]
        }
        init<Value>(existing: EnvironmentValues, key: any EnvironmentKey<Value>.Type, value: Value) {
            values = existing.values.merging([ObjectIdentifier(key): value]) { $1 }
        }
        subscript<Value>(key: any EnvironmentKey<Value>.Type) -> Value {
            values[ObjectIdentifier(key)] as? Value ?? key.defaultValue
        }
    }

    private var stack: [EnvironmentValues] = []

    private var current: EnvironmentValues {
        stack.last ?? EnvironmentValues()
    }

    internal func value<Value>(key: any EnvironmentKey<Value>.Type) -> Value {
        current[key]
    }

    internal func push<Value>(key: any EnvironmentKey<Value>.Type, value: Value) {
        stack.append(EnvironmentValues(existing: current, key: key, value: value))
    }

    internal func pop() {
        stack.removeLast()
    }

    internal func with<Value, Result>(key: any EnvironmentKey<Value>.Type, value: Value, accessor: () throws -> Result) rethrows -> Result {
        push(key: key, value: value)
        let result = try accessor()
        pop()
        return result
    }
}

@frozen @propertyWrapper public struct Environment<Value> {
    let key: any EnvironmentKey<Value>.Type

    public init(_ key: any EnvironmentKey<Value>.Type) {
        self.key = key
    }

    public var wrappedValue: Value {
        EnvironmentManager.shared.value(key: key)
    }
}

public protocol EnvironmentKey<Value> {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

public struct EnvironmentComponent<Value, Child: Component>: Component {
    let key: any EnvironmentKey<Value>.Type
    let value: Value
    let child: Child

    public func layout(_ constraint: Constraint) -> Child.R {
        EnvironmentManager.shared.with(key: key, value: value) {
            child.layout(constraint)
        }
    }
}

public extension Component {
    func environment<Value>(_ key: any EnvironmentKey<Value>.Type, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(key: key, value: value, child: self)
    }
}

public struct CurrentComponentViewEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ComponentDisplayableView? {
        nil
    }
}
