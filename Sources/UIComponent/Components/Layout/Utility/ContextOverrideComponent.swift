//  Created by Luke Zhao on 4/24/25.




public struct ContextOverrideComponent<Content: Component>: ComponentWrapper {
    public let content: Content
    public let overrideContext: [String: Any]
    public init(content: Content, overrideContext: [String: Any]) {
        self.overrideContext = overrideContext
        self.content = content
    }
    public func layout(_ constraint: Constraint) -> Content.R {
        content.layout(constraint)
    }
    public func contextValue<V>(for key: ComponentContextKey<V>) -> V? {
        if let value = overrideContext[key.rawValue] as? V {
            return value
        } else {
            return content.contextValue(for: key)
        }
    }
}
