//  Created by Luke Zhao on 8/22/20.

import Foundation

public protocol Component {
  func layout(_ constraint: Constraint) -> RenderNode
}
