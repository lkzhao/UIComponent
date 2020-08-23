//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public protocol ViewElement: Element {
  associatedtype R: ViewRenderer
  func layout(_ constraint: Constraint) -> R
}

extension ViewElement {
  public func layout(_ constraint: Constraint) -> Renderer {
    layout(constraint) as R
  }
}
