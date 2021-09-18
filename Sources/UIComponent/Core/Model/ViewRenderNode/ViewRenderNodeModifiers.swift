//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol ViewRenderNodeWrapper: ViewRenderNode {
  associatedtype Content: ViewRenderNode
  var content: Content { get }
}

extension ViewRenderNodeWrapper {
  public var id: String? {
    content.id
  }
  public var reuseKey: String? {
    "\(type(of: self))"
  }
  public var animator: Animator? {
    content.animator
  }
  public var size: CGSize {
    content.size
  }
  public func updateView(_ view: Content.View) {
    content.updateView(view)
  }
  public func makeView() -> Content.View {
    content.makeView()
  }
}

public struct ViewUpdateRenderNode<View, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  public let update: (View) -> Void

  public func updateView(_ view: View) {
    content.updateView(view)
    update(view)
  }
}

public struct ViewKeyPathUpdateRenderNode<View, Value, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  public let valueKeyPath: ReferenceWritableKeyPath<View, Value>
  public let value: Value

  public func updateView(_ view: View) {
    content.updateView(view)
    view[keyPath: valueKeyPath] = value
  }
}

public struct ViewIDRenderNode<View, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  public let id: String?
}

public struct ViewAnimatorRenderNode<View, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  public let animator: Animator?
}

public struct ViewReuseKeyRenderNode<View, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  public let reuseKey: String?
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

public struct ViewAnimatorWrapperRenderNode<View, Content: ViewRenderNode>: ViewRenderNodeWrapper where Content.View == View {
  public let content: Content
  var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
  var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
  var deleteBlock: ((ComponentDisplayableView, UIView, () -> Void) -> Void)?
  public var animator: Animator {
    let wrapper = WrapperAnimator()
    wrapper.content = content.animator
    wrapper.insertBlock = insertBlock
    wrapper.deleteBlock = deleteBlock
    wrapper.updateBlock = updateBlock
    return wrapper
  }
}

extension ViewRenderNode {
  func animateUpdate(_ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> ViewAnimatorWrapperRenderNode<View, Self> {
    ViewAnimatorWrapperRenderNode(content: self, updateBlock: updateBlock)
  }
  func animateInsert(_ insertBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> ViewAnimatorWrapperRenderNode<View, Self> {
    ViewAnimatorWrapperRenderNode(content: self, insertBlock: insertBlock)
  }
  func animateDelete(_ deleteBlock: @escaping ((ComponentDisplayableView, UIView, () -> Void) -> Void)) -> ViewAnimatorWrapperRenderNode<View, Self> {
    ViewAnimatorWrapperRenderNode(content: self, deleteBlock: deleteBlock)
  }
}
