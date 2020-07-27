//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import Foundation

public struct ForEach<S: Sequence, D>: ProviderBuilderComponent where S.Element == D {
  public var providers: [Provider]
  
  public init(_ data: S, @ProviderBuilder _ content: (D) -> ProviderBuilderComponent) {
    providers = data.flatMap { content($0).providers }
  }
  
  private init(providers: [Provider]) {
    self.providers = providers
  }
}

public extension ForEach {
  func join(@ProviderBuilder _ content: () -> ProviderBuilderComponent) -> Self {
    var result: [Provider] = []
    for i in 0..<providers.count - 1 {
      result.append(providers[i])
      result.append(contentsOf: content().providers)
    }
    if let lastProvider = providers.last {
      result.append(lastProvider)
    }
    return ForEach(providers: result)
  }
}
