//
//  ComponentBuilder.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@_functionBuilder
public struct ComponentBuilder {
  public static func buildBlock(_ segments: ComponentBuilderItem...) -> ComponentBuilderItem {
    return segments.flatMap { $0.components }
  }
  public static func buildIf(_ segments: ComponentBuilderItem?...) -> ComponentBuilderItem {
    return segments.flatMap { $0?.components ?? [] }
  }
  public static func buildEither(first: ComponentBuilderItem) -> ComponentBuilderItem {
    return first
  }
  public static func buildEither(second: ComponentBuilderItem) -> ComponentBuilderItem {
    return second
  }
}

// MARK: ComponentBuilderItem

public protocol ComponentBuilderItem {
  var components: [Component] { get }
}

public extension ComponentBuilderItem {
  func join(@ComponentBuilder _ content: () -> ComponentBuilderItem) -> ComponentBuilderItem {
    let components = self.components
    var result: [Component] = []
    for i in 0..<components.count - 1 {
      result.append(components[i])
      result.append(contentsOf: content().components)
    }
    if let lastComponent = components.last {
      result.append(lastComponent)
    }
    return result
  }
}

// MARK: Array: ComponentBuilderItem

extension Array: ComponentBuilderItem where Element == Component {
  public var components: [Component] {
    self
  }
}

extension Array {
  public func mapComponent(@ComponentBuilder _ content: (Element) -> ComponentBuilderItem) -> ComponentBuilderItem {
    return flatMap { element in
      content(element).components
    }
  }
}
