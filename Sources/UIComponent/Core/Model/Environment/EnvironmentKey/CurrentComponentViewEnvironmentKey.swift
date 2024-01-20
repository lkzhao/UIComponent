//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/20/24.
//

import Foundation

/// A environment key that holds a reference to the current `ComponentDisplayableView` displaying the component.
public struct CurrentComponentViewEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ComponentDisplayableView? {
        nil
    }
}

public extension EnvironmentValues {
    /// The current ``ComponentView`` displaying the component, if one exists.
    ///
    /// You can access the current ``ComponentView`` via the ``Environment`` property wrapper inside the ``Component/layout(_:)`` method:
    /// ```swift
    /// @Environment(\.currentComponentView) var currentComponentView
    /// ```
    var currentComponentView: ComponentDisplayableView? {
        get { self[CurrentComponentViewEnvironmentKey.self] }
        set { self[CurrentComponentViewEnvironmentKey.self] = newValue }
    }
}
