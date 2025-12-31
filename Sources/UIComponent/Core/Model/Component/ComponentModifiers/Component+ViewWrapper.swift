extension Component {
    /// Wraps the component in a platform view.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a platform view.
    public func view() -> ViewWrapperComponent<PlatformView> {
        ViewWrapperComponent(component: self)
    }

    /// Wraps the component in a `View`.
    /// - Parameter viewType: The type of view to use as the wrapper.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a `View`.
    public func view<View: PlatformView>(as viewType: View.Type) -> ViewWrapperComponent<View> {
        ViewWrapperComponent(component: self)
    }

    /// Wraps the component in a `PlatformScrollView`.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a `PlatformScrollView`.
    public func scrollView() -> ViewWrapperComponent<PlatformScrollView> {
        ViewWrapperComponent(component: self)
    }
}
