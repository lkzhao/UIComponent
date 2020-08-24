//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import Foundation

public struct ForEach<S: Sequence, D>: ComponentFunctionBuilderItem where S.Element == D {
  public var components: [Component]
  
  public init(_ data: S, @ComponentFunctionBuilder _ content: (D) -> ComponentFunctionBuilderItem) {
    components = data.flatMap { content($0).components }
  }
  
  private init(components: [Component]) {
    self.components = components
  }
}
