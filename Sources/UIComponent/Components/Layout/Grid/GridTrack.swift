//  Created by y H on 2022/4/6.

import CoreGraphics

public enum GridTrack: Equatable, Hashable {
  case fr(CGFloat)
  case pt(CGFloat)
  
  var isFlexible: Bool {
    switch self {
    case .fr:
      return true
    case .pt:
      return false
    }
  }
}
