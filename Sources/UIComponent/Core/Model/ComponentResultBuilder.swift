//
//  ComponentResultBuilder.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@resultBuilder
public struct ComponentResultBuilder {
  public static func buildExpression<A, B>(_ expression: ForEach<A, B>) -> [Component] {
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

public extension Array where Element: Component {
  func join(@ComponentResultBuilder _ content: () -> [Component]) -> [Component] {
    let components = self
    var result: [Component] = []
    for i in 0..<components.count - 1 {
      result.append(components[i])
      result.append(contentsOf: content())
    }
    if let lastComponent = components.last {
      result.append(lastComponent)
    }
    return result
  }
}
