//
//  Component.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public protocol Component: ComponentBuilderItem {
  func build() -> Element
}

public extension Component {
  var components: [Component] {
    return [self]
  }
}
