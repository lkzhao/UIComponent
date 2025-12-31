#if !os(tvOS)
@available(iOS 14.0, macOS 11.0, *)
public extension Component {
    /// Wrap the content in a component that displays the provided menu when tapped.
    /// - Parameter menu: A `PlatformMenu` to be displayed when the component is tapped.
    /// - Returns: A `PrimaryMenuComponent` containing the component and the menu.
    func primaryMenu(_ menu: PlatformMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menu: menu)
    }

    /// Wrap the content in a component that displays the provided menu when tapped.
    /// - Parameter menuBuilder: A closure that returns a `PlatformMenu` to be displayed when tapped.
    /// - Returns: A `PrimaryMenuComponent` containing the component and displays the menu when tapped.
    func primaryMenu(_ menuBuilder: @escaping () -> PlatformMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menuBuilder: menuBuilder)
    }

    /// Wrap the content in a component that displays the provided menu when tapped.
    /// - Parameter menuBuilder: A closure that returns a `PlatformMenu` to be displayed when tapped.
    /// - Returns: A `PrimaryMenuComponent` containing the component and displays the menu when tapped.
    func primaryMenu(_ menuBuilder: @escaping (PrimaryMenu) -> PlatformMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menuBuilder: menuBuilder)
    }
}
#endif
