//  Created by Luke Zhao on 4/24/25.

import UIKit

/// A keys store for defining the context keys.
///
/// To define a new context key, extend this struct and add a new property with a computed property that returns a new instance of `ComponentContextKey`.
/// For example:
/// ```swift
/// extension ComponentContextKeys {
///     public var myCustomKey: ComponentContextKey<MyCustomType> { .init(rawValue: "myCustomKey") }
/// }
/// ```
public struct ComponentContextKeys {
    public static let shared = ComponentContextKeys()
    public var supportLazyLayout: ComponentContextKey<Bool> { .init(rawValue: "supportLazyLayout") }
    public var flexGrow: ComponentContextKey<CGFloat> { .init(rawValue: "flexGrow") }
    public var flexShrink: ComponentContextKey<CGFloat> { .init(rawValue: "flexShrink") }
    public var alignSelf: ComponentContextKey<CGFloat> { .init(rawValue: "alignSelf") }
}
