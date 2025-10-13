import UIKit

extension Component {
    /// Conditionally applies a modification to the component if the given boolean value is true.
    /// - Parameters:
    ///   - value: A `Bool` that determines whether the modification should be applied.
    ///   - apply: A closure that takes the current component and returns a modified component.
    /// - Returns: The modified component if `value` is true, otherwise the original component.
    public func `if`(_ value: Bool, apply: (Self) -> any Component) -> AnyComponent {
        value ? apply(self).eraseToAnyComponent() : self.eraseToAnyComponent()
    }
}
