//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/12/21.
//

import Foundation

public struct Overlay: Component {
  let child: Component
  let overlay: Component

  public func layout(_ constraint: Constraint) -> Renderer {
    let childRenderer = child.layout(constraint)
    let overlayRenderer = overlay.layout(Constraint(minSize: childRenderer.size, maxSize: childRenderer.size))
    return SlowRenderer(size: childRenderer.size, children: [childRenderer, overlayRenderer], positions: [.zero, .zero])
  }
}


public extension Component {
  func overlay(_ component: Component) -> Overlay {
    Overlay(child: self, overlay: component)
  }
}

