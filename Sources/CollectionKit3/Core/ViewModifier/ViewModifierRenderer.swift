//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct ViewModifierRenderer<View, Value, Content: ViewRenderer>: ViewRenderer where Content.View == View {

  let content: Content
  let keyPath: ReferenceWritableKeyPath<View, Value>
  let value: Value
  
  public var id: String {
    content.id
  }
  public var animator: Animator? {
    content.animator
  }
  public var size: CGSize {
    content.size
  }
  public func updateView(_ view: View) {
    content.updateView(view)
    view[keyPath: keyPath] = value
  }
  public func makeView() -> View {
    content.makeView()
  }
}

public struct ViewIDModifierRenderer<View, Content: ViewRenderer>: ViewRenderer where Content.View == View {

  let content: Content
  public let id: String

  public var size: CGSize {
    content.size
  }
  public var animator: Animator? {
    content.animator
  }
  public func updateView(_ view: View) {
    content.updateView(view)
  }
  public func makeView() -> View {
    content.makeView()
  }
}

extension ViewRenderer {
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> ViewModifierRenderer<View, Value, Self> {
    return ViewModifierRenderer(content: self, keyPath: keyPath, value: value)
  }
  public func id(_ id: String) -> ViewIDModifierRenderer<View, Self> {
    return ViewIDModifierRenderer(content: self, id: id)
  }
}
