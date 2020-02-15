//
//  AnimatorOverride.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2/12/20.
//

import UIKit

public extension AnyViewProvider {
  func animator(_ animator: Animator) -> AnyViewProvider {
    AnimatorOverrideProvider(child: self, animator: animator)
  }
}

private struct AnimatorOverrideProvider: AnyViewProvider {
  var child: AnyViewProvider

  var key: String {
    return child.key
  }

  var animator: Animator?

  init(child: AnyViewProvider, animator: Animator) {
    self.child = child
    self.animator = animator
  }

  func sizeThatFits(_ size: CGSize) -> CGSize {
    child.sizeThatFits(size)
  }

  func _makeView() -> UIView {
    return child._makeView()
  }

  func _updateView(_ view: UIView) {
    child._updateView(view)
  }
}
