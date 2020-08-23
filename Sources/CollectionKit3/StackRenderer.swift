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

extension StackRenderer {
  public func views(in frame: CGRect) -> [Renderable] {
    var result = [Renderable]()
    var index = positions.binarySearch { main($0) < main(frame.origin) - mainAxisMaxValue }
    while index < positions.count {
      let childFrame = CGRect(origin: positions[index], size: children[index].size)
      if main(childFrame.origin) >= main(frame.origin) + main(frame.size) {
        break
      }
      if main(childFrame.origin) + main(childFrame.size) > main(frame.origin) {
        let child = children[index]
        let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map { info in
          Renderable(id: info.id, animator: info.animator, renderer: info.renderer,
                     frame: CGRect(origin: info.frame.origin + childFrame.origin, size: info.frame.size))
        }
        result.append(contentsOf: childResult)
      }
      index += 1
    }
    return result
  }
}

public struct RowRenderer: StackRenderer, VerticalLayoutProtocol {
  public let size: CGSize
  public let children: [Renderer]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}

public struct ColumnRenderer: StackRenderer, HorizontalLayoutProtocol {
  public let size: CGSize
  public let children: [Renderer]
  public let positions: [CGPoint]
  public let mainAxisMaxValue: CGFloat
}
