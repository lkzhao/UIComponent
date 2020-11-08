//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/26/20.
//

import UIKit

public struct ZStack: Component {
  public enum VerticalAlignment {
    case top, center, bottom, stretch
  }
  public enum HorizontalAlignment {
    case leading, center, trailing, stretch
  }

  public var verticalAlignment: VerticalAlignment = .center
  public var horizontalAlignment: HorizontalAlignment = .center
  public var children: [Component]

  public func layout(_ constraint: Constraint) -> Renderer {
    var renderers: [Renderer] = children.map {
      $0.layout(constraint)
    }
    let size = CGSize(width: renderers.max { $0.size.width < $1.size.width }?.size.width ?? 0,
                      height: renderers.max { $0.size.height < $1.size.height }?.size.height ?? 0).bound(to: constraint)
    let positions: [CGPoint] = renderers.enumerated().map { (idx, node) in
      var result = CGRect(origin: .zero, size: node.size)
      switch verticalAlignment {
      case .top:
        result.origin.y = 0
      case .center:
        result.origin.y = (size.height - node.size.height) / 2
      case .bottom:
        result.origin.y = size.height - node.size.height
      case .stretch:
        result.size.height = size.height
      }
      switch horizontalAlignment {
      case .leading:
        result.origin.x = 0
      case .center:
        result.origin.x = (size.width - node.size.width) / 2
      case .trailing:
        result.origin.x = size.width - node.size.width
      case .stretch:
        result.size.width = size.width
      }
      if node.size != result.size {
        renderers[idx] = children[idx].layout(.tight(result.size))
      }
      return result.origin
    }
    return SlowRenderer(size: size, children: renderers, positions: positions)
  }
}

public extension ZStack {
  init(verticalAlignment: VerticalAlignment = .center, horizontalAlignment: HorizontalAlignment = .center, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(verticalAlignment: verticalAlignment, horizontalAlignment: horizontalAlignment, children: content().components)
  }
}
