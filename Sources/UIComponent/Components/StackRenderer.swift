//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public protocol StackRenderer: Renderer, BaseLayoutProtocol {
  var size: CGSize { get }
  var children: [Renderer] { get }
  var positions: [CGPoint] { get }
  var mainAxisMaxValue: CGFloat { get }
}

public extension StackRenderer {
  func frame(at index: Int) -> CGRect? {
    guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
    return CGRect(origin: position, size: size)
  }

  func views(in frame: CGRect) -> [Renderable] {
    guard var index = firstVisibleIndex(in: frame) else { return [] }
    var result: [Renderable] = []
    let endPoint = main(frame.origin) + main(frame.size)
    while index < positions.count, main(positions[index]) < endPoint {
      let childFrame = CGRect(origin: positions[index], size: children[index].size)
      let childResult = children[index].views(in: frame.intersection(childFrame) - childFrame.origin).map {
        Renderable(id: $0.id, animator: $0.animator, renderer: $0.renderer,
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

public struct HorizontalRenderer: StackRenderer, HorizontalLayoutProtocol {
  public let size: CGSize
  public let children: [Renderer]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}

public struct VerticalRenderer: StackRenderer, VerticalLayoutProtocol {
  public let size: CGSize
  public let children: [Renderer]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}

public struct SlowRenderer: Renderer {
  public let size: CGSize
  public let children: [Renderer]
  public let positions: [CGPoint]
  
  public init(size: CGSize, children: [Renderer], positions: [CGPoint]) {
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
          Renderable(id: $0.id, animator: $0.animator, renderer: $0.renderer, frame: CGRect(origin: $0.frame.origin + childFrame.origin, size: $0.frame.size))
        }
        result.append(contentsOf: childResult)
      }
    }

    return result
  }
}
