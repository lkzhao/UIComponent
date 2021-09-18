//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol StackRenderNode: RenderNode, BaseLayoutProtocol {
  var size: CGSize { get }
  var children: [RenderNode] { get }
  var positions: [CGPoint] { get }
  var mainAxisMaxValue: CGFloat { get }
}

extension StackRenderNode {
  public func visibleIndexes(in frame: CGRect) -> IndexSet {
    guard let start = firstVisibleIndex(in: frame) else { return [] }
    var index = start
    let endPoint = main(frame.origin) + main(frame.size)
    while index < positions.count, main(positions[index]) < endPoint {
      index += 1
    }
    return IndexSet(start..<index)
  }

  public func firstVisibleIndex(in frame: CGRect) -> Int? {
    let beginPoint = main(frame.origin) - mainAxisMaxValue
    let endPoint = main(frame.origin) + main(frame.size)
    var index = positions.binarySearch { main($0) < beginPoint }
    while index < positions.count, main(positions[index]) < endPoint {
      if main(positions[index]) + main(children[index].size) > main(frame.origin) {
        return index
      }
      index += 1
    }
    return nil
  }
}

public struct HorizontalRenderNode: StackRenderNode, HorizontalLayoutProtocol {
  public let size: CGSize
  public let children: [RenderNode]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}

public struct VerticalRenderNode: StackRenderNode, VerticalLayoutProtocol {
  public let size: CGSize
  public let children: [RenderNode]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}

public struct SlowRenderNode: RenderNode {
  public let size: CGSize
  public let children: [RenderNode]
  public let positions: [CGPoint]

  public init(size: CGSize, children: [RenderNode], positions: [CGPoint]) {
    self.size = size
    self.children = children
    self.positions = positions
  }

  public func visibleIndexes(in frame: CGRect) -> IndexSet {
    var result = [Int]()

    for (i, origin) in positions.enumerated() {
      let child = children[i]
      let childFrame = CGRect(origin: origin, size: child.size)
      if frame.intersects(childFrame) {
        result.append(i)
      }
    }

    return IndexSet(result)
  }
}
