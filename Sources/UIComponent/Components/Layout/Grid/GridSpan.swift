//  Created by y H on 2022/4/2.

public struct GridSpan: Component {
  public static let `default` = GridSpan(child: Space())

  public var column: Int
  public var row: Int
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
  func gridSpan(column: Int = 1, row: Int = 1) -> GridSpan {
    GridSpan(column: column, row: row, child: self)
  }
}
