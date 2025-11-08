//
//  ForegroundColorEnvironmentKey.swift
//  UIComponent
//
//  Created by y H on 2025/6/25.
//

import UIKit

/// The key for accessing the default font from the environment.
public struct ForegroundColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: UIColor? { nil }
}

public extension EnvironmentValues {
    /// The foregroundColor value in the environment.
    var foregroundColor: UIColor? {
        get {
            self[ForegroundColorEnvironmentKey.self]
        } set {
            self[ForegroundColorEnvironmentKey.self] = newValue
        }
    }
}

public extension Component {
    /// Sets the color of the foreground elements displayed by this view.
    ///
    /// - Parameter color: The foreground color to use when displaying this
    ///   view. Pass `nil` to remove any custom foreground color and to allow
    ///   the system or the container to provide its own foreground color.
    ///   If a container-specific override doesn't exist, the system uses
    ///   the primary color.
    ///
    /// - Returns: An environment component with the new foregroundColor value.
    func foregroundColor(_ color: UIColor?) -> EnvironmentComponent<UIColor?, Self> {
        environment(\.foregroundColor, value: color)
    }
}
