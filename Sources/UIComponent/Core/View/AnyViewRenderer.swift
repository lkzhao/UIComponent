//
//  AnyViewRenderer.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public protocol AnyViewRenderer: Renderer {
  var id: String { get }
  var animator: Animator? { get }
  func _makeView() -> UIView
  func _updateView(_ view: UIView)
}

public extension AnyViewRenderer {
  var animator: Animator? { nil }

  func views(in frame: CGRect) -> [Renderable] {
    let childFrame = CGRect(origin: .zero, size: size)
    if frame.intersects(childFrame) {
      return [Renderable(id: id,
                         animator: animator,
                         renderer: self,
                         frame: childFrame)]
    }
    return []
  }
}
