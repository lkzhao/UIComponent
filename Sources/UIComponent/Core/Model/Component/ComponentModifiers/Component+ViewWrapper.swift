extension Component {
    /// Wraps the component in a `UIView`.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a UIView.
    public func view() -> ViewWrapperComponent<UIView> {
        ViewWrapperComponent(component: self)
    }

    /// Wraps the component in a `View`.
    /// - Parameter viewType: The type of view to use as the wrapper.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a `View`.
    public func view<View: UIView>(as viewType: View.Type) -> ViewWrapperComponent<View> {
        ViewWrapperComponent(component: self)
    }

    /// Wraps the component in a `UIScrollView`.
    /// - Returns: A `ViewWrapperComponent` that renders the component within a `UIScrollView`.
    public func scrollView() -> ViewWrapperComponent<UIScrollView> {
        ViewWrapperComponent(component: self)
    }
}
