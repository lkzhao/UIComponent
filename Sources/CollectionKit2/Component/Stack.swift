//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

public struct ZStack: LayoutProvider {
  public enum VerticalAlignment {
    case top, center, bottom, stretch
  }
  public enum HorizontalAlignment {
    case leading, center, trailing, stretch
  }

  public var verticalAlignment: VerticalAlignment = .center
  public var horizontalAlignment: HorizontalAlignment = .center
  public var children: [Provider]

  public var isSortedLayout: Bool {
    return false
  }

  public func simpleLayout(size: CGSize) -> ([LayoutNode], [CGRect]) {
    var layoutNodes: [LayoutNode] = children.map { getLayoutNode(child: $0, maxSize: size) }
    let width: CGFloat = layoutNodes.max { $0.size.width < $1.size.width }?.size.width ?? 0
    let height: CGFloat = layoutNodes.max { $0.size.height < $1.size.height }?.size.height ?? 0
    let frames: [CGRect] = layoutNodes.enumerated().map { (idx, node) in
      var result = CGRect(origin: .zero, size: node.size)
      switch verticalAlignment {
      case .top:
        result.origin.y = 0
      case .center:
        result.origin.y = (height - node.size.height) / 2
      case .bottom:
        result.origin.y = height - node.size.height
      case .stretch:
        result.size.height = height
      }
      switch horizontalAlignment {
      case .leading:
        result.origin.x = 0
      case .center:
        result.origin.x = (width - node.size.width) / 2
      case .trailing:
        result.origin.x = width - node.size.width
      case .stretch:
        result.size.width = width
      }
      if node.size != result.size {
        layoutNodes[idx] = getLayoutNode(child: children[idx], maxSize: result.size)
      }
      return result
    }
    return (layoutNodes, frames)
  }
}

public extension ZStack {
  init(verticalAlignment: VerticalAlignment = .center, horizontalAlignment: HorizontalAlignment = .center, @ProviderBuilder _ content: () -> ProviderBuilderComponent) {
    self.init(verticalAlignment: verticalAlignment, horizontalAlignment: horizontalAlignment, children: content().providers)
  }
}
