//
//  PageLayout.swift
//  CollectionKit3
//
//  Created by Luke Zhao on 2019-01-23.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public struct PageLayout: LayoutProvider {
  let children: [Provider]
  public func simpleLayout(size: CGSize) -> ([LayoutNode], [CGRect]) {
    var frames: [CGRect] = []
    var nodes: [LayoutNode] = []
    for (i, c) in children.enumerated() {
      let node = getLayoutNode(child: c, maxSize: size)
      frames.append(CGRect(origin: CGPoint(x: CGFloat(i) * size.width, y: 0), size: node.size))
      nodes.append(node)
    }
    return (nodes, frames)
  }
}
