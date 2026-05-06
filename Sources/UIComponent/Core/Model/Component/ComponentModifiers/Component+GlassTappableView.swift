extension Component {
    /// Creates a glass tappable view component from the current component with a tap action. See ``GlassTappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func glassTappableView(
        _ onTap: @escaping (GlassTappableView) -> Void
    ) -> GlassTappableViewComponent {
        GlassTappableViewComponent(
            component: self,
            onTap: onTap
        )
    }

    /// Creates a glass tappable view component from the current component with a tap action. See ``GlassTappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func glassTappableView(
        _ onTap: @escaping () -> Void
    ) -> GlassTappableViewComponent {
        glassTappableView { _ in
            onTap()
        }
    }
}
