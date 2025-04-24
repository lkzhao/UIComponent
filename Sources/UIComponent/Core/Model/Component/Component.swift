//  Created by Luke Zhao on 8/22/20.

import Foundation

/// Basic building block of UIComponent.
/// The only method that it require is ``Component/layout(_:)`` which calculates
/// the layout of the component and generate a ``RenderNode``
@dynamicMemberLookup
public protocol Component<R> {
    /// The type of `RenderNode` that this component produces.
    associatedtype R: RenderNode

    /// Calculates the layout of the component within the given constraints and
    /// returns a `RenderNode` representing the result.
    ///
    /// - Parameter constraint: The constraints within which the component must lay itself out.
    /// - Returns: A `RenderNode` representing the laid out component.
    func layout(_ constraint: Constraint) -> R

    func contextValue<V>(for key: ComponentContextKey<V>) -> V?
}

public extension Component {
    func contextValue<V>(for key: ComponentContextKey<V>) -> V? {
        nil
    }

    func contextValue<V>(for keyPath: KeyPath<ComponentContextKeys, ComponentContextKey<V>>) -> V? {
        contextValue(for: ComponentContextKeys.shared[keyPath: keyPath])
    }
}
