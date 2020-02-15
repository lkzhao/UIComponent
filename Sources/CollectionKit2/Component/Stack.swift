//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

public struct ZStack: LayoutProvider {
  public enum Alignment {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
  }

  public var alignment: Alignment = .center
  public var children: [Provider]

  public var isSortedLayout: Bool {
    return false
  }

  public func simpleLayout(size: CGSize) -> ([LayoutNode], [CGRect]) {
    let layoutNodes: [LayoutNode] = children.map { getLayoutNode(child: $0, maxSize: size) }
    let width: CGFloat = layoutNodes.max { $0.size.width < $1.size.width }?.size.width ?? 0
    let height: CGFloat = layoutNodes.max { $0.size.height < $1.size.height }?.size.height ?? 0
    let frames: [CGRect] = layoutNodes.map { node in
      let x: CGFloat
      let y: CGFloat
      switch alignment {
      case .topLeading, .top, .topTrailing:
        y = 0
      case .leading, .center, .trailing:
        y = (height - node.size.height) / 2
      case .bottomLeading, .bottom, .bottomTrailing:
        y = height - node.size.height
      }
      switch alignment {
      case .topLeading, .leading, .bottomLeading:
        x = 0
      case .top, .center, .bottom:
        x = (width - node.size.width) / 2
      case .topTrailing, .trailing, .bottomTrailing:
        x = width - node.size.width
      }
      return CGRect(x: x, y: y, width: node.size.width, height: node.size.height)
    }
    return (layoutNodes, frames)
  }
}

public extension ZStack {
  init(alignment: Alignment = .center, @ProviderBuilder _ content: () -> ProviderBuilderComponent) {
    self.init(alignment: alignment, children: content().providers)
  }
}
