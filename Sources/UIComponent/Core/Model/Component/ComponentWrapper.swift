//  Created by Luke Zhao on 4/24/25.




public protocol ComponentWrapper: Component {
    associatedtype Content: Component
    var content: Content { get }
}

public extension ComponentWrapper {
    func contextValue<V>(for key: ComponentContextKey<V>) -> V? {
        content.contextValue(for: key)
    }
}
