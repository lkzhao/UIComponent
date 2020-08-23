//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public struct ViewModifierComponent<View, Value, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  public typealias R = ViewModifierRenderer<View, Value, Content.R>
  let content: Content
  let keyPath: ReferenceWritableKeyPath<View, Value>
  let value: Value
  
  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).with(keyPath, value)
  }
}

public struct ViewIDModifierComponent<View, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  
  public typealias R = ViewIDModifierRenderer<View, Content.R>
  let content: Content
  let id: String

  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).id(id)
  }
}

extension ViewComponent {
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewModifierComponent<R.View, Value, Self> {
    return ViewModifierComponent(content: self, keyPath: keyPath, value: value)
  }
  public func id(_ id: String) -> ViewIDModifierComponent<R.View, Self> {
    return ViewIDModifierComponent(content: self, id: id)
  }
}
