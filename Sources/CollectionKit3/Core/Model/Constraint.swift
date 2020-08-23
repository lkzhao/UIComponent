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
  
  public static func tight(_ size: CGSize) -> Constraint {
    Constraint(maxSize: size, minSize: size)
  }
  
  public func inset(by insets: UIEdgeInsets) -> Constraint {
    Constraint(maxSize: CGSize(width: max(0, maxSize.width == .infinity ? .infinity : maxSize.width - insets.left - insets.right),
                               height: max(0, maxSize.height == .infinity ? .infinity : maxSize.height - insets.top - insets.bottom)),
               minSize: CGSize(width: max(0, minSize.width == .infinity ? .infinity : minSize.width - insets.left - insets.right),
                               height: max(0, minSize.height == .infinity ? .infinity : minSize.height - insets.top - insets.bottom)))
  }
}

public extension CGSize {
  func constraint(to constraint: Constraint) -> CGSize {
    CGSize(width: width.clamp(constraint.minSize.width, constraint.maxSize.width),
           height: height.clamp(constraint.minSize.height, constraint.maxSize.height))
  }
}
