//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation


@dynamicMemberLookup
public protocol ViewComponent: Component {
  associatedtype R: ViewRenderer
  func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
  public func layout(_ constraint: Constraint) -> Renderer {
    layout(constraint) as R
  }
}
