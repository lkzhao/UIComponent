//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public struct ViewModifierElement<View, Value, Content: ViewElement>: ViewElement where Content.R.View == View {
  public typealias R = ViewModifierRenderer<View, Value, Content.R>
  let content: Content
  let keyPath: ReferenceWritableKeyPath<View, Value>
  let value: Value
  
  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).with(keyPath, value)
  }
}

public struct ViewIDModifierElement<View, Content: ViewElement>: ViewElement where Content.R.View == View {
  
  public typealias R = ViewIDModifierRenderer<View, Content.R>
  let content: Content
  let id: String

  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).id(id)
  }
}

extension ViewElement {
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewModifierElement<R.View, Value, Self> {
    return ViewModifierElement(content: self, keyPath: keyPath, value: value)
  }
  public func id(_ id: String) -> ViewIDModifierElement<R.View, Self> {
    return ViewIDModifierElement(content: self, id: id)
  }
}
