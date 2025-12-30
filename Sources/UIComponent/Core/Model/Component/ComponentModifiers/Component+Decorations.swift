extension Component {
    // MARK: - Background modifiers

    /// Wraps the component with a background component.
    /// - Parameter component: The component to be used as the background.
    /// - Returns: A `Background` component that layers the background behind the current component.
    public func background(_ component: any Component) -> Background {
        Background(content: self, background: component)
    }

    /// Wraps the component with a background component, using a closure that returns the background component.
    /// - Parameter component: A closure that returns the component to be used as the background.
    /// - Returns: A `Background` component that layers the background behind the current component.
    public func background(_ component: () -> any Component) -> Background {
        Background(content: self, background: component())
    }

    // MARK: - Overlay modifiers

    /// Wraps the component with an overlay component.
    /// - Parameter component: The component to be used as the overlay.
    /// - Returns: An `Overlay` component that layers the overlay on top of the current component.
    public func overlay(_ component: any Component) -> Overlay {
        Overlay(content: self, overlay: component)
    }

    /// Wraps the component with an overlay component, using a closure that returns the overlay component.
    /// - Parameter component: A closure that returns the component to be used as the overlay.
    /// - Returns: An `Overlay` component that layers the overlay on top of the current component.
    public func overlay(_ component: () -> any Component) -> Overlay {
        Overlay(content: self, overlay: component())
    }

    // MARK: - Badge modifiers

    /// Adds a badge to the component with specified alignments and offset.
    /// - Parameters:
    ///   - component: The component to be used as the badge.
    ///   - verticalAlignment: The vertical alignment of the badge. Defaults to `.start`.
    ///   - horizontalAlignment: The horizontal alignment of the badge. Defaults to `.end`.
    ///   - offset: The offset point for the badge. Defaults to `.zero`.
    /// - Returns: A `Badge` component that places the badge relative to the current component.
    public func badge(
        _ component: any Component,
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero
    ) -> Badge {
        Badge(
            content: self,
            overlay: component,
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }

    /// Adds a badge to the component with specified alignments and offset, using a closure that returns the badge component.
    /// - Parameters:
    ///   - verticalAlignment: The vertical alignment of the badge. Defaults to `.start`.
    ///   - horizontalAlignment: The horizontal alignment of the badge. Defaults to `.end`.
    ///   - offset: The offset point for the badge. Defaults to `.zero`.
    ///   - component: A closure that returns the component to be used as the badge.
    /// - Returns: A `Badge` component that places the badge relative to the current component.
    public func badge(
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero,
        _ component: () -> any Component
    ) -> Badge {
        Badge(
            content: self,
            overlay: component(),
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }
}
