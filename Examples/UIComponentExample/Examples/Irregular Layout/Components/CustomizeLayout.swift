//
//  CustomizeLayout.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/30.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

struct CustomizeLayout: Component {
  
  let blockFrames: (_ constraint: Constraint) -> [CGRect]
  
  public let children: [Component]
  
  init(@ComponentArrayBuilder _ content: () -> [Component], blockFrames: @escaping (_ constraint: Constraint) -> [CGRect]) {
    self.blockFrames = blockFrames
    self.children = content()
  }
  
  func layout(_ constraint: Constraint) -> Renderer {
    
    let frames = blockFrames(constraint)
    
    let frame = frames.reduce(frames.first ?? .zero) {
      $0.union($1)
    }
    return SlowRenderer(size: CGSize(width: frame.maxX, height: frame.maxY),
                        children: zip(children, frames).map({ $0.0.layout(.tight($0.1.size)) }),
                        positions: frames.map({ $0.origin }))
  }
  
}
