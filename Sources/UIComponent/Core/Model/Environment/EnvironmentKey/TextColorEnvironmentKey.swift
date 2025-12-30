//  Created by Luke Zhao on 2024-12-17.

/// The key for accessing the default text color from the environment.
public struct TextColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: UIColor? {
        nil
    }
}

public extension EnvironmentValues {
    /// The text color value in the environment.
    var textColor: UIColor? {
        get { self[TextColorEnvironmentKey.self] }
        set { self[TextColorEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    /// Modifies the text color environment value for the component.
    /// - Parameter color: The UIColor to be set in the environment.
    /// - Returns: An environment component with the new text color value.
    func textColor(_ color: UIColor?) -> EnvironmentComponent<UIColor?, Self> {
        environment(\.textColor, value: color)
    }
}
