//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol ViewRendererWrapper: ViewRenderer {
  associatedtype Content: ViewRenderer
  var content: Content { get }
}

extension ViewRendererWrapper {
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

public struct ViewUpdateRenderer<View, Content: ViewRenderer>: ViewRendererWrapper where Content.View == View {
  public let content: Content
  public let update: (View) -> Void

  public func updateView(_ view: View) {
    content.updateView(view)
    update(view)
  }
}

public struct ViewKeyPathUpdateRenderer<View, Value, Content: ViewRenderer>: ViewRendererWrapper where Content.View == View {
  public let content: Content
  public let valueKeyPath: ReferenceWritableKeyPath<View, Value>
  public let value: Value
  
  public func updateView(_ view: View) {
    content.updateView(view)
    view[keyPath: valueKeyPath] = value
  }
}

public struct ViewIDRenderer<View, Content: ViewRenderer>: ViewRendererWrapper where Content.View == View {
  public let content: Content
  public let id: String?
}

public struct ViewAnimatorRenderer<View, Content: ViewRenderer>: ViewRendererWrapper where Content.View == View {
  public let content: Content
  public let animator: Animator?
}

public struct ViewReuseKeyRenderer<View, Content: ViewRenderer>: ViewRendererWrapper where Content.View == View {
  public let content: Content
  public let reuseKey: String?
}
