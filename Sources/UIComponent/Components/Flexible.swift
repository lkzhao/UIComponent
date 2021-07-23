//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct Flexible: Component {
  public let flex: CGFloat
  public let alignSelf: CrossAxisAlignment?
  public let child: Component
  public func layout(_ constraint: Constraint) -> Renderer {
    child.layout(constraint)
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible {
    Flexible(flex: flex, alignSelf: alignSelf, child: self)
  }
}

public typealias Spacer = Flexible
public extension Spacer {
  init() {
    self.init(flex: 1, alignSelf: nil, child: Space())
  }
}
