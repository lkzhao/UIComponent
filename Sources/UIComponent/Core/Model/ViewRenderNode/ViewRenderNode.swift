//  Created by Luke Zhao on 8/22/20.

import UIKit

@dynamicMemberLookup
public protocol ViewRenderNode: AnyViewRenderNode {
  associatedtype View: UIView
  func makeView() -> View
  func updateView(_ view: View)
}

public extension ViewRenderNode {
  // MARK: Default
  func makeView() -> View {
    View()
  }
  // MARK: AnyViewRenderNode
  func _makeView() -> UIView {
    if let reuseKey = reuseKey {
      return ReuseManager.shared.dequeue(identifier: reuseKey, makeView())
    }
    return makeView()
  }
  func _updateView(_ view: UIView) {
    guard let view = view as? View else { return }
    return updateView(view)
  }
}
