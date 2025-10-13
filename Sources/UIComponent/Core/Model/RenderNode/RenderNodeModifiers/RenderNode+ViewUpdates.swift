import UIKit

/// A render node that store an update block to be applied to the view during reloads.
public struct UpdateRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let update: (Content.View) -> Void

    public var shouldRenderView: Bool {
        true // UIView has custom property. So we should render it.
    }

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        update(view)
    }
}

/// A render node that applies a value to a specific key path of the view.
public struct KeyPathUpdateRenderNode<Value, Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let valueKeyPath: ReferenceWritableKeyPath<Content.View, Value>
    public let value: Value

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        view[keyPath: valueKeyPath] = value
    }

    public var shouldRenderView: Bool {
        true // UIView has custom property. So we should render it.
    }
}

extension RenderNode {
    /// Accesses a dynamic member using a key path to the view's properties.
    /// - Parameter keyPath: A key path to a specific property of the view.
    /// - Returns: A closure that takes a new value for the property and returns a `KeyPathUpdateRenderNode`.
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Value>) -> (Value) -> KeyPathUpdateRenderNode<Value, Self> {
        { with(keyPath, $0) }
    }

    /// Creates a render node that updates a specific property of the view.
    /// - Parameters:
    ///   - keyPath: A key path to the specific property of the view to be updated.
    ///   - value: The new value to be set for the property.
    /// - Returns: A `KeyPathUpdateRenderNode` with the new value applied.
    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> KeyPathUpdateRenderNode<Value, Self> {
        KeyPathUpdateRenderNode(content: self, valueKeyPath: keyPath, value: value)
    }

    /// Creates a render node that applies a custom update to the view.
    /// - Parameter update: A closure that defines how the view should be updated.
    /// - Returns: An `UpdateRenderNode` that uses the custom update closure.
    public func update(_ update: @escaping (View) -> Void) -> UpdateRenderNode<Self> {
        UpdateRenderNode(content: self, update: update)
    }
}
