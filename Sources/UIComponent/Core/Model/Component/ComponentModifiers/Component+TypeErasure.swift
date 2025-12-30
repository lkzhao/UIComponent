extension Component {
    /// Wraps the current component in a type-erased ``AnyComponent`` container.
    /// - Returns: A type erased ``AnyComponent`` that renders the same view as the current component.
    public func eraseToAnyComponent() -> AnyComponent {
        AnyComponent(content: self)
    }

    /// Wraps the current component in a type-erased ``AnyComponentOfView`` container.
    /// - Returns: A type erased``AnyComponentOfView`` that renders the same view as the current component.
    public func eraseToAnyComponentOfView() -> AnyComponentOfView<R.View> {
        AnyComponentOfView(content: self)
    }
}
