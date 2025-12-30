//  Created by Luke Zhao on 1/20/24.

/// A environment key that holds a reference to the current hosting view displaying the component.
public struct HostingViewEnvironmentKey: EnvironmentKey {
    public static var defaultValue: PlatformView? {
        nil
    }
    public static var isWeak: Bool {
        true
    }
}

public extension EnvironmentValues {
    /// The current hosting view displaying the component, if one exists.
    /// This is a built-in environment value that is automatically populated during a reload.
    ///
    /// You can access the current hosting view via the ``Environment`` property wrapper inside the ``Component/layout(_:)`` method:
    /// ```swift
    /// @Environment(\.hostingView) var hostingView
    /// ```
    var hostingView: PlatformView? {
        get { self[HostingViewEnvironmentKey.self] }
        set { self[HostingViewEnvironmentKey.self] = newValue }
    }
}
