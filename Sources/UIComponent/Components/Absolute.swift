//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/29/20.
//

import UIKit

public struct Absolute: Component {
  public var children: [Component]
  public var frames: [CGRect]

  public init(children: [Component], frames: [CGRect]) {
    self.children = children
    self.frames = frames
  }
  
  public func layout(_ constraint: Constraint) -> Renderer {
    let frame = frames.reduce(frames.first ?? .zero) {
      $0.union($1)
    }
    return SlowRenderer(size: CGSize(width: frame.maxX, height: frame.maxY),
                        children: zip(children, frames).map({ $0.0.layout(.tight($0.1.size)) }),
                        positions: frames.map({ $0.origin }))
  }
}
