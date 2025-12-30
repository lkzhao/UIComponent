//  Created by Luke Zhao on 1/20/24.

/// The key for accessing the default font from the environment.
public struct FontEnvironmentKey: EnvironmentKey {
    public static var defaultValue: PlatformFont? {
        nil
    }
}

public extension EnvironmentValues {
    /// The font value in the environment.
    var font: PlatformFont? {
        get { self[FontEnvironmentKey.self] }
        set { self[FontEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    /// Modifies the font environment value for the component.
    /// - Parameter font: The PlatformFont to be set in the environment.
    /// - Returns: An environment component with the new font value.
    func font(_ font: PlatformFont?) -> EnvironmentComponent<PlatformFont?, Self> {
        environment(\.font, value: font)
    }
}
