//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/20/24.
//

import UIKit

/// The key for accessing the default font from the environment.
public struct FontEnvironmentKey: EnvironmentKey {
    public static var defaultValue: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
}

public extension EnvironmentValues {
    /// The font value in the environment.
    var font: UIFont {
        get { self[FontEnvironmentKey.self] }
        set { self[FontEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    /// Modifies the font environment value for the component.
    /// - Parameter font: The UIFont to be set in the environment.
    /// - Returns: An environment component with the new font value.
    func font(_ font: UIFont) -> EnvironmentComponent<UIFont, Self> {
        environment(\.font, value: font)
    }
}
