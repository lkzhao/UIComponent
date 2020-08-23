//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public protocol ViewComponent: Component {
  associatedtype E: ViewElement
  func build() -> Self.E
}

extension ViewComponent {
  public func build() -> Element {
    build() as E
  }
}
