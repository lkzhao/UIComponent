//  Created by Luke Zhao on 4/24/25.


/// A protocol that wraps a content `Component` to and pass through the context.
/// Its component methods can be overriden by the conforming type.
public protocol ComponentWrapper: Component {
    associatedtype Content: Component
    var content: Content { get }
}

public extension ComponentWrapper {
    func contextValue<V>(for key: ComponentContextKey<V>) -> V? {
        content.contextValue(for: key)
    }
}
