//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public enum FlexItemAlign: CaseIterable {
    case start, end, center, stretch, auto
}


public struct Flexible: Component {
  public let flex: CGFloat
  public let alignSelf: FlexItemAlign
  public let child: Component
  public func layout(_ constraint: Constraint) -> Renderer {
    child.layout(constraint)
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, alignSelf: FlexItemAlign = .auto) -> Flexible {
    Flexible(flex: flex, alignSelf: alignSelf, child: self)
  }
}

public typealias Spacer = Flexible
public extension Spacer {
  init() {
    self.init(flex: 1, alignSelf: .auto, child: Space())
  }
}
