/// A component produced by the ``Component/update(_:)`` modifier
public typealias UpdateComponent<Content: Component> = ModifierComponent<Content, UpdateRenderNode<Content.R>>

/// A component produced by the ``Component/with(_:_:)`` modifier
public typealias KeyPathUpdateComponent<Content: Component, Value> = ModifierComponent<Content, KeyPathUpdateRenderNode<Value, Content.R>>

extension Component {
    /// Provides a closure that acts as a modifier that can be used to modify a view property. This is used to support @dynamicMemberLookup, it should not be used directly.
    /// Example:
    /// ```swift
    /// ViewComponent<MyView>().myCustomProperty(value)
    /// ```
    /// - Parameter keyPath: A key path to a specific writable property on the underlying view.
    /// - Returns: A closure that takes a new value for the property and returns a `KeyPathUpdateComponent` representing the component with the updated value.
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> KeyPathUpdateComponent<Self, Value> {
        { value in
            with(keyPath, value)
        }
    }

    /// Applies a value to a property of the underlying view specified by a key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific property on the underlying view.
    ///   - value: The value to set for the property specified by keyPath.
    /// - Returns: A `KeyPathUpdateComponent` that represents the modified component.
    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> KeyPathUpdateComponent<Self, Value> {
        ModifierComponent(content: self) {
            $0.with(keyPath, value)
        }
    }

    /// Registers a closure to be called when the component is updated.
    /// - Parameter update: A closure that takes the component's underlying view as its parameter.
    /// - Returns: An `UpdateComponent` that represents the modified component with an update closure.
    public func update(_ update: @escaping (R.View) -> Void) -> UpdateComponent<Self> {
        ModifierComponent(content: self) {
            $0.update(update)
        }
    }

    /// Applies a rounded corner effect to the component by setting the `cornerRadius` of the view's layer.
    /// The radius is set to half of the minimum of the view's width and height, resulting in a circular shape if the view is square.
    public func roundedCorner() -> UpdateComponent<Self> {
        ModifierComponent(content: self) { node in
            node.update { view in
#if os(macOS)
                view.wantsLayer = true
                view.layer?.cornerRadius = min(node.size.width, node.size.height) / 2
#else
                view.layer.cornerRadius = min(node.size.width, node.size.height) / 2
#endif
            }
        }
    }
}
