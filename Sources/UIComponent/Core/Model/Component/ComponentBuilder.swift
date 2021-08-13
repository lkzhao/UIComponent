//  Created by Luke Zhao on 8/23/20.

import Foundation

public protocol ComponentBuilder: Component {
  func build() -> Component
}

public extension ComponentBuilder {
  func layout(_ constraint: Constraint) -> RenderNode {
    build().layout(constraint)
  }
}
