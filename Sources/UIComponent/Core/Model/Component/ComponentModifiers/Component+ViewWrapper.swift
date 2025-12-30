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
#if canImport(UIKit)
    public func scrollView() -> ViewWrapperComponent<UIScrollView> {
        ViewWrapperComponent(component: self)
    }
#elseif os(macOS)
    /// Wraps the component in an `NSScrollView`.
    /// - Returns: A `MacScrollViewWrapperComponent` that renders the component within an `NSScrollView`.
    public func scrollView() -> MacScrollViewWrapperComponent {
        MacScrollViewWrapperComponent(component: self)
    }
#endif
}
