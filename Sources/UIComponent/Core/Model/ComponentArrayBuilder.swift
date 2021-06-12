//
//  ComponentArrayBuilder.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@resultBuilder
public struct ComponentArrayBuilder {
  public static func buildExpression(_ expression: Join) -> [Component] {
    expression.components
  }
  public static func buildExpression(_ expression: Component) -> [Component] {
    [expression]
  }
  public static func buildBlock(_ segments: [Component]...) -> [Component] {
    segments.flatMap { $0 }
  }
  public static func buildIf(_ segments: [Component]?...) -> [Component] {
    segments.flatMap { $0 ?? [] }
  }
  public static func buildEither(first: [Component]) -> [Component] {
    first
  }
  public static func buildEither(second: [Component]) -> [Component] {
    second
  }
  public static func buildArray(_ components: [[Component]]) -> [Component] {
    components.flatMap { $0 }
  }
  public static func buildLimitedAvailability(_ component: [Component]) -> [Component] {
    component
  }
}
