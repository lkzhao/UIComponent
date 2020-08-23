//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct Insets: Component {
  public let insets: UIEdgeInsets
  public let child: Component
  public func layout(_ constraint: Constraint) -> Renderer {
    InsetsRenderer(child: child.layout(constraint.inset(by: insets)), insets: insets)
  }
}

struct InsetsRenderer: Renderer {
  let child: Renderer
  let insets: UIEdgeInsets
  var size: CGSize {
    return child.size.inset(by: -insets)
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: -insets)).map {
      Renderable(id: $0.id, animator: $0.animator, renderer: $0.renderer, frame: $0.frame + CGPoint(x: insets.left, y: insets.top))
    }
  }
}

public extension Component {
  func inset(by insets: UIEdgeInsets) -> Insets {
    Insets(insets: insets, child: self)
  }
}
