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
  public func build() -> Element {
    FlexibleElement(flex: flex, fit: fit, child: child.build())
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, fit: FlexFit = .tight) -> Flexible {
    Flexible(flex: flex, fit: fit, child: self)
  }
}

struct FlexibleElement: Element {
  let flex: CGFloat
  let fit: FlexFit
  let child: Element
  func layout(_ constraint: Constraint) -> Renderer {
    child.layout(constraint)
  }
}
