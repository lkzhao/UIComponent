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
