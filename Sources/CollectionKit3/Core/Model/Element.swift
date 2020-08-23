//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public protocol Element {
  func layout(_ constraint: Constraint) -> Renderer
}
