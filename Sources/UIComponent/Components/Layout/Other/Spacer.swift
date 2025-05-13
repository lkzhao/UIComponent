//  Created by Luke Zhao on 8/6/21.

import CoreGraphics

/// A flexible component that expand to fill the remaining space inside any flex layout (``FlexColumn``, ``FlexRow``, ``Flow``, ``HStack``, ``VStack``).
public struct Spacer: ComponentBuilder {
    public init() {}
    public func build() -> some Component {
        Space().flex()
    }
}
