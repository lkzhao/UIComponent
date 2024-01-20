//  Created by Luke Zhao on 1/11/24.

import Foundation

internal enum EnvironmentValuesKey<Value> {
    case keyPath(WritableKeyPath<EnvironmentValues, Value>)
    case keyType(any EnvironmentKey<Value>.Type)
}

public struct EnvironmentValues {
    private var values: [ObjectIdentifier: Any] = [:]

    public subscript<Value>(keyType: any EnvironmentKey<Value>.Type) -> Value {
        get {
            values[ObjectIdentifier(keyType)] as? Value ?? keyType.defaultValue
        }
        set {
            values[ObjectIdentifier(keyType)] = newValue
        }
    }

    private static var stack: [EnvironmentValues] = []
    public private(set) static var current = EnvironmentValues()

    internal static func saveCurrentValues() {
        stack.append(current)
    }

    internal static func restoreCurrentValues() {
        guard let last = stack.popLast() else {
            assertionFailure("Inbalanced environment save/restore")
            return
        }
        current = last
    }

    internal static func with<Value, Result>(key: EnvironmentValuesKey<Value>, value: Value, accessor: () throws -> Result) rethrows -> Result {
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

    public static func with<Value, Result>(_ keyType: any EnvironmentKey<Value>.Type, value: Value, accessor: () throws -> Result) rethrows -> Result {
        try with(key: .keyType(keyType), value: value, accessor: accessor)
    }

    public static func with<Value, Result>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value, accessor: () throws -> Result) rethrows -> Result {
        try with(key: .keyPath(keyPath), value: value, accessor: accessor)
    }
}

@frozen @propertyWrapper public struct Environment<Value> {
    public enum EnvironmentAccessorKey {
        case keyPath(KeyPath<EnvironmentValues, Value>)
        case keyType(any EnvironmentKey<Value>.Type)
    }
    let key: EnvironmentAccessorKey

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.key = .keyPath(keyPath)
    }

    public init(_ keyType: any EnvironmentKey<Value>.Type) {
        self.key = .keyType(keyType)
    }

    public var wrappedValue: Value {
        switch key {
        case let .keyPath(keyPath):
            EnvironmentValues.current[keyPath: keyPath]
        case let .keyType(keyType):
            EnvironmentValues.current[keyType]
        }
    }
}

public protocol EnvironmentKey<Value> {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

public struct EnvironmentComponent<Value, Content: Component>: Component {
    let key: EnvironmentValuesKey<Value>
    let value: Value
    let content: Content

    public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value, content: Content) {
        self.key = .keyPath(keyPath)
        self.value = value
        self.content = content
    }

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

public struct WeakEnvironmentComponent<Value: AnyObject, Content: Component>: Component {
    let key: EnvironmentValuesKey<Value?>
    weak var value: Value?
    let content: Content

    public init(keyPath: WritableKeyPath<EnvironmentValues, Value?>, value: Value?, content: Content) {
        self.key = .keyPath(keyPath)
        self.value = value
        self.content = content
    }

    public init(keyType: any EnvironmentKey<Value?>.Type, value: Value?, content: Content) {
        self.key = .keyType(keyType)
        self.value = value
        self.content = content
    }

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


public extension Component {
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyPath: keyPath, value: value, content: self)
    }
    func environment<Value>(_ keyType: any EnvironmentKey<Value>.Type, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyType: keyType, value: value, content: self)
    }
    func weakEnvironment<Value: AnyObject>(_ keyPath: WritableKeyPath<EnvironmentValues, Value?>, value: Value?) -> WeakEnvironmentComponent<Value, Self> {
        WeakEnvironmentComponent(keyPath: keyPath, value: value, content: self)
    }
    func weakEnvironment<Value: AnyObject>(_ keyType: any EnvironmentKey<Value?>.Type, value: Value?) -> WeakEnvironmentComponent<Value, Self> {
        WeakEnvironmentComponent(keyType: keyType, value: value, content: self)
    }
}

public struct CurrentComponentViewEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ComponentDisplayableView? {
        nil
    }
}

public extension EnvironmentValues {
    var currentComponentView: ComponentDisplayableView? {
        get { self[CurrentComponentViewEnvironmentKey.self] }
        set { self[CurrentComponentViewEnvironmentKey.self] = newValue }
    }
}
