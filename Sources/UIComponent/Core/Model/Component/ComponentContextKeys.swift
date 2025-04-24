//  Created by Luke Zhao on 4/24/25.

import UIKit

public struct ComponentContextKeys {
    public static let shared = ComponentContextKeys()
    public var supportLazyLayout: ComponentContextKey<Bool> { .init(rawValue: "supportLazyLayout") }
    public var flexGrow: ComponentContextKey<CGFloat> { .init(rawValue: "flexGrow") }
    public var flexShrink: ComponentContextKey<CGFloat> { .init(rawValue: "flexShrink") }
    public var alignSelf: ComponentContextKey<CGFloat> { .init(rawValue: "alignSelf") }
}
