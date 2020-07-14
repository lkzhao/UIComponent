//
//  File.swift
//  
//
//  Created by Luke Zhao on 7/13/20.
//

import UIKit

public struct AbsoluteLayout: LayoutProvider {
  public var children: [Provider]
  public var frames: [CGRect]

  public init(children: [Provider], frames: [CGRect]) {
    self.children = children
    self.frames = frames
  }

  public func simpleLayoutWithCustomSize(size: CGSize) -> (([LayoutNode], [CGRect]), CGSize) {
    return ((children.map { getLayoutNode(child: $0, maxSize: size) }, frames), size)
  }
}
