#if canImport(UIKit)
extension Component {
    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - configuration: Optional `TappableViewConfig` to configure the tappable view.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    @available(*, deprecated, message: "Use .tappableView(_:).tappableViewConfig(_:) instead")
    public func tappableView(
        configuration: TappableViewConfig,
        _ onTap: @escaping (TappableView) -> Void
    ) -> EnvironmentComponent<TappableViewConfig, TappableViewComponent> {
        TappableViewComponent(
            component: self,
            onTap: onTap
        ).tappableViewConfig(configuration)
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - configuration: Optional `TappableViewConfig` to configure the tappable view.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    @available(*, deprecated, message: "Use .tappableView(_:).tappableViewConfig(_:) instead")
    public func tappableView(
        configuration: TappableViewConfig,
        _ onTap: @escaping () -> Void
    ) -> EnvironmentComponent<TappableViewConfig, TappableViewComponent> {
        tappableView(configuration: configuration) { _ in
            onTap()
        }
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func tappableView(
        _ onTap: @escaping (TappableView) -> Void
    ) -> TappableViewComponent {
        TappableViewComponent(
            component: self,
            onTap: onTap
        )
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func tappableView(
        _ onTap: @escaping () -> Void
    ) -> TappableViewComponent {
        tappableView { _ in
            onTap()
        }
    }
}
#endif
