//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol StackRenderNode: RenderNode, BaseLayoutProtocol {
  var size: CGSize { get }
  var children: [RenderNode] { get }
  var positions: [CGPoint] { get }
  var mainAxisMaxValue: CGFloat { get }
}

public extension StackRenderNode {
  func views(in frame: CGRect) -> [Renderable] {
    guard var index = firstVisibleIndex(in: frame) else { return [] }
    var result: [Renderable] = []
    let endPoint = main(frame.origin) + main(frame.size)
    while index < positions.count, main(positions[index]) < endPoint {
      let childFrame = CGRect(origin: positions[index], size: children[index].size)
      let childResult = children[index].views(in: frame.intersection(childFrame) - childFrame.origin).map {
        Renderable(id: $0.id,
                   keyPath: "\(type(of: self))-\(index)." + $0.keyPath,
                   animator: $0.animator, renderNode: $0.renderNode,
                   frame: CGRect(origin: $0.frame.origin + childFrame.origin, size: $0.frame.size))
      }
      result.append(contentsOf: childResult)
      index += 1
    }
    return result
  }

  func firstVisibleIndex(in frame: CGRect) -> Int? {
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
  
  public func views(in frame: CGRect) -> [Renderable] {
    var result = [Renderable]()

    for (i, origin) in positions.enumerated() {
      let child = children[i]
      let childFrame = CGRect(origin: origin, size: child.size)
      if frame.intersects(childFrame) {
        let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
          Renderable(id: $0.id,
                     keyPath: "slow-\(i)." + $0.keyPath,
                     animator: $0.animator,
                     renderNode: $0.renderNode,
                     frame: CGRect(origin: $0.frame.origin + childFrame.origin, size: $0.frame.size))
        }
        result.append(contentsOf: childResult)
      }
    }

    return result
  }
}
