//  Created by Luke Zhao on 8/6/21.

import Foundation

/// # Spacer Component
///
/// A flexible component that expand to fill the remaining space inside any flex layout (`FlexColumn`, `FlexRow`, `Flow`, `HStack`, `VStack`).
public typealias Spacer = Flexible
extension Spacer {
  public init() {
    self.init(flex: 1, alignSelf: nil, child: Space())
  }
}
