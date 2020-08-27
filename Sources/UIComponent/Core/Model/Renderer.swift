//
//  Renderer.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import CoreGraphics

public protocol Renderer {
  /// size of the Renderer
  var size: CGSize { get }
  
  /// Get items' view and its rect within the frame in current component's coordinates.
  /// - Parameter frame: Parent component's visible frame in current component's coordinates.
  func views(in frame: CGRect) -> [Renderable]
}
