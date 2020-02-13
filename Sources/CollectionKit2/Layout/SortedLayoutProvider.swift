//
//  SortedLayoutProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public struct SlowLayoutNode: LayoutNode {
  let children: [LayoutNode]
  let frames: [CGRect]
  public let size: CGSize

  public func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    var result = [(AnyViewProvider, CGRect)]()

    for (i, childFrame) in frames.enumerated() where frame.intersects(childFrame) {
      let child = children[i]
      let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map { viewProvider, frame in
        (viewProvider, CGRect(origin: frame.origin + childFrame.origin, size: frame.size))
      }
      result.append(contentsOf: childResult)
    }

    return result
  }
}

public struct HSortedLayoutNode: LayoutNode {
  let children: [LayoutNode]
  let frames: [CGRect]
  let maxFrameLength: CGFloat
  public let size: CGSize
  
  public init(children: [LayoutNode], frames: [CGRect], size: CGSize) {
    self.maxFrameLength = frames.max { $0.width < $1.width }?.width ?? 0
    self.children = children
    self.frames = frames
    self.size = size
  }
  
  public func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    var result = [(AnyViewProvider, CGRect)]()
    var index = frames.binarySearch { $0.minX < frame.minX - maxFrameLength }
    while index < frames.count {
      let childFrame = frames[index]
      if childFrame.minX >= frame.maxX {
        break
      }
      if childFrame.maxX > frame.minX {
        let child = children[index]
        let childFrame = frames[index]
        let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
          ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
        }
        result.append(contentsOf: childResult)
      }
      index += 1
    }
    return result
  }
}

public struct VSortedLayoutNode: LayoutNode {
  public let children: [LayoutNode]
  public let frames: [CGRect]
  public let maxFrameLength: CGFloat
  public let size: CGSize
  
  public init(children: [LayoutNode], frames: [CGRect], size: CGSize) {
    self.maxFrameLength = frames.max { $0.height < $1.height }?.height ?? 0
    self.children = children
    self.frames = frames
    self.size = size
  }
  
  public func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    var result = [(AnyViewProvider, CGRect)]()
    var index = frames.binarySearch { $0.minY < frame.minY - maxFrameLength }
    while index < frames.count {
      let childFrame = frames[index]
      if childFrame.minY >= frame.maxY {
        break
      }
      if childFrame.maxY > frame.minY {
        let child = children[index]
        let childFrame = frames[index]
        let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
          ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
        }
        result.append(contentsOf: childResult)
      }
      index += 1
    }
    return result
  }
}
