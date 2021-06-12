//
//  File.swift
//  
//
//  Created by Luke Zhao on 5/16/21.
//

import UIKit

public struct Background: Component {
  let child: Component
  let background: Component

  public func layout(_ constraint: Constraint) -> Renderer {
    let childRenderer = child.layout(constraint)
    let backgroundRenderer = background.layout(Constraint(minSize: childRenderer.size, maxSize: childRenderer.size))
    return SlowRenderer(size: childRenderer.size, children: [backgroundRenderer, childRenderer], positions: [.zero, .zero])
  }
}

public extension Component {
  func background(_ component: Component) -> Background {
    Background(child: self, background: component)
  }
}

