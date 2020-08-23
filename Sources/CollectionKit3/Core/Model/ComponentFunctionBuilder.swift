//
//  ComponentFunctionBuilder.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@_functionBuilder
public struct ComponentFunctionBuilder {
  public static func buildBlock(_ segments: ComponentFunctionBuilderItem...) -> ComponentFunctionBuilderItem {
    return segments.flatMap { $0.components }
  }
  public static func buildIf(_ segments: ComponentFunctionBuilderItem?...) -> ComponentFunctionBuilderItem {
    return segments.flatMap { $0?.components ?? [] }
  }
  public static func buildEither(first: ComponentFunctionBuilderItem) -> ComponentFunctionBuilderItem {
    return first
  }
  public static func buildEither(second: ComponentFunctionBuilderItem) -> ComponentFunctionBuilderItem {
    return second
  }
}

// MARK: ComponentFunctionBuilderItem

public protocol ComponentFunctionBuilderItem {
  var components: [Component] { get }
}

public extension ComponentFunctionBuilderItem {
  func join(@ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) -> ComponentFunctionBuilderItem {
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

// MARK: Array: ComponentFunctionBuilderItem

extension Array: ComponentFunctionBuilderItem where Element == Component {
  public var components: [Component] {
    self
  }
}

extension Array {
  public func mapComponent(@ComponentFunctionBuilder _ content: (Element) -> ComponentFunctionBuilderItem) -> ComponentFunctionBuilderItem {
    return flatMap { element in
      content(element).components
    }
  }
}
