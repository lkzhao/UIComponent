//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol AnyViewRenderNode: RenderNode {
  var id: String? { get }
  var keyPath: String { get }
  var animator: Animator? { get }
  var reuseKey: String? { get }
  func _makeView() -> UIView
  func _updateView(_ view: UIView)
}

public extension AnyViewRenderNode {
  var id: String? { nil }
  var animator: Animator? { nil }
  var keyPath: String { "\(type(of: self))" }
  var reuseKey: String? { "\(type(of: self))" }
  var children: [RenderNode] { [] }
  var positions: [CGPoint] { [] }

  func views(in frame: CGRect) -> [Renderable] {
    let childFrame = CGRect(origin: .zero, size: size)
    if frame.intersects(childFrame) {
      return [Renderable(id: id,
                         keyPath: keyPath,
                         animator: animator,
                         renderNode: self,
                         frame: childFrame)]
    }
    return []
  }
}
