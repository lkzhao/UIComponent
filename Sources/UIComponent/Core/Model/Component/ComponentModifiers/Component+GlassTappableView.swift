extension Component {
    /// Creates a glass tappable view component from the current component with a tap action. See ``GlassTappableView`` for detail.
    /// - Parameters:
    ///   - tintColor: The tint of the glass; nil for clear glass.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func glassTappableView(
        tintColor: UIColor? = nil,
        _ onTap: @escaping (GlassTappableView) -> Void
    ) -> GlassTappableViewComponent {
        GlassTappableViewComponent(
            component: self,
            tintColor: tintColor,
            onTap: onTap
        )
    }

    /// Creates a glass tappable view component from the current component with a tap action. See ``GlassTappableView`` for detail.
    /// - Parameters:
    ///   - tintColor: The tint of the glass; nil for clear glass.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func glassTappableView(
        tintColor: UIColor? = nil,
        _ onTap: @escaping () -> Void
    ) -> GlassTappableViewComponent {
        glassTappableView(tintColor: tintColor) { _ in
            onTap()
        }
    }
}
