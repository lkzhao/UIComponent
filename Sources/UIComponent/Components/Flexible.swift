//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public enum FlexFit {
  case tight, loose
}

public struct Flexible: Component {
  public let flex: CGFloat
  public let fit: FlexFit
  public let child: Component
  public func layout(_ constraint: Constraint) -> Renderer {
    child.layout(constraint)
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, fit: FlexFit = .tight) -> Flexible {
    Flexible(flex: flex, fit: fit, child: self)
  }
}

public typealias Spacer = Flexible
public extension Spacer {
  init() {
    self.init(flex: 1, fit: .tight, child: Space())
  }
}
