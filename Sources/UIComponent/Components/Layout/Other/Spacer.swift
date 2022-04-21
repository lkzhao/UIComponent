//  Created by Luke Zhao on 8/6/21.

import CoreGraphics

/// # Spacer Component
///
/// A flexible component that expand to fill the remaining space inside any flex layout (`FlexColumn`, `FlexRow`, `Flow`, `HStack`, `VStack`).
public typealias Spacer = Flexible
extension Spacer {
  public init() {
    self.init(flexGrow: 1, flexShrink: 0, alignSelf: nil, child: Space())
  }
}
