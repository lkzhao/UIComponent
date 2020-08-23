//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct Constraint {
  public var maxSize: CGSize
  public var minSize: CGSize
  
  static func tight(_ size: CGSize) -> Constraint {
    Constraint(maxSize: size, minSize: size)
  }
}
