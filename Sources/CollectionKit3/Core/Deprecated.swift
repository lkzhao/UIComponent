//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import Foundation

public typealias Provider = Component
public typealias ProviderDisplayableView = ComponentDisplayableView

public extension ComponentEngine {
  var provider: Component? {
    get { component }
    set { component = newValue }
  }
}

public extension ComponentDisplayable {
  var provider: Component? {
    get { engine.component }
    set { engine.component = newValue }
  }
}
