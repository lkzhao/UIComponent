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

extension ViewRenderNode {
  subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Value>) -> (Value) -> ViewKeyPathUpdateRenderNode<View, Value, Self> {
    { with(keyPath, $0) }
  }
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> ViewKeyPathUpdateRenderNode<View, Value, Self> {
    ViewKeyPathUpdateRenderNode(content: self, valueKeyPath: keyPath, value: value)
  }
  public func id(_ id: String) -> ViewIDRenderNode<View, Self> {
    ViewIDRenderNode(content: self, id: id)
  }
  public func animator(_ animator: Animator?) -> ViewAnimatorRenderNode<View, Self> {
    ViewAnimatorRenderNode(content: self, animator: animator)
  }
  public func reuseKey(_ reuseKey: String?) -> ViewReuseKeyRenderNode<View, Self> {
    ViewReuseKeyRenderNode(content: self, reuseKey: reuseKey)
  }
  public func update(_ update: @escaping (View) -> Void) -> ViewUpdateRenderNode<View, Self> {
    ViewUpdateRenderNode(content: self, update: update)
  }
}
