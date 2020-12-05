//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/26/20.
//

import Foundation

public struct LayoutReader: Component {
  let child: Component
  let reader: (Renderer) -> Void
  
  public init(child: Component, _ reader: @escaping (Renderer) -> Void) {
    self.child = child
    self.reader = reader
  }

  public func layout(_ constraint: Constraint) -> Renderer {
    let renderer = child.layout(constraint)
    reader(renderer)
    return renderer
  }
}

public extension Component {
  func layoutReader(_ reader: @escaping (Renderer) -> Void) -> LayoutReader {
    LayoutReader(child: self, reader)
  }
}
