extension Component {
    /// Conditionally applies a modification to the component if the given boolean value is true.
    /// - Parameters:
    ///   - value: A `Bool` that determines whether the modification should be applied.
    ///   - apply: A closure that takes the current component and returns a modified component.
    ///   - else: An optional closure that will be invoked when `value` is false.
    /// - Returns: The modified component if `value` is true, otherwise the original component or the `else` result.
    public func `if`(
        _ value: Bool,
        apply: (Self) -> any Component,
        else other: ((Self) -> any Component)? = nil
    ) -> AnyComponent {
        if value {
            return apply(self).eraseToAnyComponent()
        }
        return other?(self).eraseToAnyComponent() ?? eraseToAnyComponent()
    }

    /// Conditionally applies a modification to the component if the given boolean value is false.
    /// - Parameters:
    ///   - value: A `Bool` that determines whether the negated condition should be applied.
    ///   - apply: A closure that takes the current component and returns a modified component when `value` is false.
    ///   - else: An optional closure that will be invoked when `value` is true.
    /// - Returns: The modified component if `value` is false, otherwise the original component or the `else` result.
    public func ifNot(
        _ value: Bool,
        apply: (Self) -> any Component,
        else other: ((Self) -> any Component)? = nil
    ) -> AnyComponent {
        `if`(!value, apply: apply, else: other)
    }
}
