//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/12/21.
//

import Foundation

public protocol ViewComponentBuilder: ViewComponent {
  associatedtype Content: ViewComponent
  func build(constraint: Constraint) -> Content
}

public extension ViewComponentBuilder {
  func layout(_ constraint: Constraint) -> Content.R {
    build(constraint: constraint).layout(constraint)
  }
}
