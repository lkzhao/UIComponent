//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

// Swift Funtion Builders
public protocol ProviderBuilderComponent {
  var providers: [Provider] { get }
}

public extension Provider {
  var providers: [Provider] {
    return [self]
  }
}

extension Array: ProviderBuilderComponent where Element == Provider {
  public var providers: [Provider] {
    self
  }
}

extension Array {
  public func mapProvider(@ProviderBuilder _ content: (Element) -> ProviderBuilderComponent) -> ProviderBuilderComponent {
    return flatMap { element in
      content(element).providers
    }
  }
}

struct InternalProviderBuilderComponent: ProviderBuilderComponent {
  var providers: [Provider]
}

@_functionBuilder
public struct ProviderBuilder {
  public static func buildBlock(_ segments: ProviderBuilderComponent...) -> ProviderBuilderComponent {
    return InternalProviderBuilderComponent(providers: segments.flatMap { $0.providers })
  }
  public static func buildIf(_ segments: ProviderBuilderComponent?...) -> ProviderBuilderComponent {
    return InternalProviderBuilderComponent(providers: segments.flatMap { $0?.providers ?? [] })
  }
  public static func buildEither(first: ProviderBuilderComponent) -> ProviderBuilderComponent {
    return first
  }
  public static func buildEither(second: ProviderBuilderComponent) -> ProviderBuilderComponent {
    return second
  }
}

extension UIView: ProviderBuilderComponent {
  public var providers: [Provider] {
    return [SimpleViewProvider(id: "view-\(self.hashValue)", view: self)]
  }
}

public extension ProviderBuilderComponent {
  func join(@ProviderBuilder _ content: () -> ProviderBuilderComponent) -> ProviderBuilderComponent {
    let providers = self.providers
    var result: [Provider] = []
    for i in 0..<providers.count - 1 {
      result.append(providers[i])
      result.append(contentsOf: content().providers)
    }
    if let lastProvider = providers.last {
      result.append(lastProvider)
    }
    return result
  }
}
