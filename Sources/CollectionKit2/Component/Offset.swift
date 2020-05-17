//
//  Offset.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2/12/20.
//

import UIKit

struct OffsetProvider: Provider {
  public var offset: CGPoint
  public var child: Provider

  public init(offset: CGPoint = .zero, child: Provider) {
    self.offset = offset
    self.child = child
  }

  public func layout(size: CGSize) -> LayoutNode {
    return OffsetLayoutNode(offset: offset, child: child.layout(size: size))
  }
}

struct OffsetLayoutNode: LayoutNode {
  let offset: CGPoint
  let child: LayoutNode
  var size: CGSize {
    return child.size
  }

  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    child.views(in: frame.offsetBy(dx: -offset.x, dy: -offset.y)).map {
      ($0.0, $0.1.offsetBy(dx: offset.x, dy: offset.y))
    }
  }
}

public extension Provider {
  func offset(_ offset: CGPoint) -> Provider {
    OffsetProvider(offset: offset, child: self)
  }

  func offset(dx: CGFloat = 0, dy: CGFloat = 0) -> Provider {
    OffsetProvider(offset: CGPoint(x: dx, y: dy), child: self)
  }
}
