//
//  SortedLayoutProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class SortedLayoutProvider: LayoutProvider {
  private var maxFrameLength: CGFloat = 0
  open var isImplementedInVertical: Bool { return true }

  open override func doneLayout() {
    if transposed == isImplementedInVertical {
      maxFrameLength = frames.max { $0.width < $1.width }?.width ?? 0
    } else {
      maxFrameLength = frames.max { $0.height < $1.height }?.height ?? 0
    }
  }

  open func visibleIndexes(in frame: CGRect) -> [Int] {
    var results = [Int]()
    if transposed == isImplementedInVertical {
      var index = frames.binarySearch { $0.minX < frame.minX - maxFrameLength }
      while index < frames.count {
        let childFrame = frames[index]
        if childFrame.minX >= frame.maxX {
          break
        }
        if childFrame.maxX > frame.minX {
          results.append(index)
        }
        index += 1
      }
    } else {
      var index = frames.binarySearch { $0.minY < frame.minY - maxFrameLength }
      while index < frames.count {
        let childFrame = frames[index]
        if childFrame.minY >= frame.maxY {
          break
        }
        if childFrame.maxY > frame.minY {
          results.append(index)
        }
        index += 1
      }
    }
    return results
  }

  open override func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    var result = [(ViewProvider, CGRect)]()
    for index in visibleIndexes(in: frame) {
      let child = children[index]
      let childFrame = frames[index]
      let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
        ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
      }
      result.append(contentsOf: childResult)
    }
    return result
  }
}
