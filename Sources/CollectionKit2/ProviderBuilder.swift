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
