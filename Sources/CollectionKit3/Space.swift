//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct Space: Component {
  let size: CGSize
  public init(size: CGSize) {
    self.size = size
  }
  public init(width: CGFloat = 0, height: CGFloat = 0) {
    size = CGSize(width: width, height: height)
  }
  public func layout(_ constraint: Constraint) -> Renderer {
    SpaceRenderer(size: size.constraint(to: constraint))
  }
}

struct SpaceRenderer: Renderer {
  let size: CGSize
  func views(in frame: CGRect) -> [Renderable] {
    []
  }
}
