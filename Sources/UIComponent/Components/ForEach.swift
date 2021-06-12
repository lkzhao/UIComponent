//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import Foundation

public struct ForEach<S: Sequence, D> where S.Element == D {
  public var components: [Component]
  
  public init(_ data: S, @ComponentResultBuilder _ content: (D) -> [Component]) {
    components = data.flatMap { content($0) }
  }
  
  private init(components: [Component]) {
    self.components = components
  }
}
