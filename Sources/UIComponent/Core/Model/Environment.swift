//  Created by Luke Zhao on 1/11/24.

import Foundation

private class EnvironmentManager {
    static let shared = EnvironmentManager()

    private var stack: [EnvironmentValues] = []

    var current: EnvironmentValues {
        stack.last ?? EnvironmentValues()
    }

    func push<K, Value>(key: K.Type, value: Value) where K : EnvironmentKey, K.Value == Value {
        stack.append(EnvironmentValues(existing: current, key: key, value: value))
    }

    func pop() {
        stack.removeLast()
    }
}

@frozen @propertyWrapper public struct Environment<Value> {
    let key: any EnvironmentKey<Value>.Type

    public init(_ key: any EnvironmentKey<Value>.Type) {
        self.key = key
    }

    public var wrappedValue: Value {
        EnvironmentManager.shared.current[key]
    }
}

public protocol EnvironmentKey<Value> {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

public struct EnvironmentValues {
    let values: [ObjectIdentifier: Any]
    public init() {
        values = [:]
    }
    public init<Value>(existing: EnvironmentValues, key: any EnvironmentKey<Value>.Type, value: Value) {
        values = existing.values.merging([ObjectIdentifier(key): value]) { $1 }
    }
    public subscript<Value>(key: any EnvironmentKey<Value>.Type) -> Value {
        values[ObjectIdentifier(key)] as? Value ?? key.defaultValue
    }

}

public struct EnvironmentComponent<Value, Child: Component>: Component {
    let key: any EnvironmentKey<Value>.Type
    let value: Value
    let child: Child

    public func layout(_ constraint: Constraint) -> Child.R {
        EnvironmentManager.shared.push(key: key, value: value)
        let result = child.layout(constraint)
        EnvironmentManager.shared.pop()
        return result
    }
}

public extension Component {
    func environment<Value>(_ key: any EnvironmentKey<Value>.Type, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(key: key, value: value, child: self)
    }
}
