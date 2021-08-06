//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/5/21.
//

import Foundation

public extension Component {
  func `if`(_ value: Bool, apply: (Self) -> Component) -> Component {
    value ? apply(self) : self
  }
}
