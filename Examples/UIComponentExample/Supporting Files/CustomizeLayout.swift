//
//  CustomizeLayout.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/30.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

struct CustomizeLayout: Component, HorizontalLayoutProtocol {
  
  let blockFrames: (_ constraint: Constraint) -> [CGRect]
  
  public let children: [Component]
  
  init(@ComponentArrayBuilder _ content: () -> [Component], blockFrames: @escaping (_ constraint: Constraint) -> [CGRect]) {
    self.blockFrames = blockFrames
    self.children = content()
  }
  
  func layout(_ constraint: Constraint) -> Renderer {
    
    let frames = blockFrames(constraint)
    
    let elements = zip(frames, children).map { frame, child in
      return (frame.origin, child.layout(Constraint(minSize: frame.size, maxSize: frame.size)))
    }
    let maxWidth = frames.reduce(CGFloat(0), {
      max($0, $1.maxX)
    })
    let maxHeight = frames.reduce(CGFloat(0), {
      max($0, $1.maxY)
    })
    return renderer(size: CGSize(width: maxWidth, height: maxHeight), children: elements.map { $0.1 }, positions: elements.map { $0.0 })
  }
  
}
