//  Created by Luke Zhao on 8/23/20.

/// A Component that builds a Component.
/// Use this instead of ``Component`` when you want to implement ``build()`` instead of ``Component/layout(_:)``.
/// This saves you from calling ``Component/layout(_:)`` on your child before returning it.
/// See <doc:CustomComponent> for detail.
public protocol ComponentBuilder: Component {
    associatedtype ResultComponent: Component
    /// Builds and returns the `ResultComponent`.
    func build() -> ResultComponent
}

extension ComponentBuilder {
    public func layout(_ constraint: Constraint) -> ResultComponent.R {
        build().layout(constraint)
    }
}
