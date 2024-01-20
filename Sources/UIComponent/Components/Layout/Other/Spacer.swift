//  Created by Luke Zhao on 8/6/21.

import CoreGraphics

/// A flexible component that expand to fill the remaining space inside any flex layout (``FlexColumn``, ``FlexRow``, ``Flow``, ``HStack``, ``VStack``).
public typealias Spacer = Flexible<Space>
extension Spacer {
    public init() {
        self.init(flexGrow: 1, flexShrink: 0, alignSelf: nil, content: Space())
    }
}
