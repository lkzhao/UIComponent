//  Created by y H on 2022/4/2.

import UIComponent

public struct GridSpanComponent: Component {
  public static let `default` = GridSpanComponent(child: Space())

  public let column: Int
  public let row: Int
  public let child: Component

  public init(column: Int = 1,
              row: Int = 1,
              child: Component)
  {
    self.column = column
    self.row = row
    self.child = child
  }

  public func layout(_ constraint: Constraint) -> RenderNode {
    child.layout(constraint)
  }
}

public extension Component {
  func gridSpan(_ column: Int = 1, row: Int) -> GridSpanComponent {
    GridSpanComponent(column: column, row: row, child: self)
  }
}
