//
//  LayoutProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol LayoutProvider: Provider {
	var isTransposed: Bool { get }
  var isSortedLayout: Bool { get }
  var isVerticalLayout: Bool { get }

	func simpleLayout(size: CGSize) -> ([LayoutNode], [CGRect])
  func simpleLayoutWithCustomSize(size: CGSize) -> (([LayoutNode], [CGRect]), CGSize)
}

extension LayoutProvider {
  public var isTransposed: Bool { return false }
  public var isSortedLayout: Bool { return true }
  public var isVerticalLayout: Bool { return true }
  
  public func simpleLayout(size _: CGSize) -> ([LayoutNode], [CGRect]) {
    fatalError("LayoutProvider subclass must implement either simpleLayout or simpleLayoutWithCustomSize")
  }

  public func simpleLayoutWithCustomSize(size: CGSize) -> (([LayoutNode], [CGRect]), CGSize) {
    let (nodes, frames) = simpleLayout(size: size)
    let contentSize = frames.reduce(CGRect.zero) { old, item in
      old.union(item)
    }.size
    return ((nodes, frames), contentSize)
  }

  public func getLayoutNode(child: Provider, maxSize: CGSize) -> LayoutNode {
    let childNode: LayoutNode
    if isTransposed {
      childNode = TransposedLayoutNode(child: child.layout(size: maxSize.transposed))
    } else {
      childNode = child.layout(size: maxSize)
    }
    assert(childNode.size.width.isFinite, "\(child)'s width is invalid")
    assert(childNode.size.height.isFinite, "\(child)'s height is invalid")
    return childNode
  }

  public func layout(size: CGSize) -> LayoutNode {
    let nodes: [LayoutNode]
    let frames: [CGRect]
    let contentSize: CGSize
    if isTransposed {
      let ((_nodes, _frames), _contentSize) = simpleLayoutWithCustomSize(size: size.transposed)
      nodes = _nodes.map { TransposedLayoutNode(child: $0) }
      frames = _frames.map { $0.transposed }
      contentSize = _contentSize.transposed
    } else {
      ((nodes, frames), contentSize) = simpleLayoutWithCustomSize(size: size)
    }
    if isSortedLayout {
      if isVerticalLayout != isTransposed {
        return VSortedLayoutNode(children: nodes, frames: frames, size: contentSize)
      } else {
        return HSortedLayoutNode(children: nodes, frames: frames, size: contentSize)
      }
    } else {
      return SlowLayoutNode(children: nodes, frames: frames, size: contentSize)
    }
  }
}

struct TransposedLayoutNode: LayoutNode {
  let child: LayoutNode
  var size: CGSize {
    return child.size.transposed
  }
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    child.views(in: frame.transposed).map { ($0.0, $0.1.transposed) }
  }
}
