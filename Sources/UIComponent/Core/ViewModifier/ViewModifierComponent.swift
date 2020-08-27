//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

public struct ViewUpdateComponent<View, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  public typealias R = ViewUpdateRenderer<View, Content.R>
  let content: Content
  let update: (View) -> Void
  
  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).update(update)
  }
}

public struct ViewModifierComponent<View, Value, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  public typealias R = ViewModifierRenderer<View, Value, Content.R>
  let content: Content
  let keyPath: ReferenceWritableKeyPath<View, Value>
  let value: Value
  
  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).with(keyPath, value)
  }
}

public struct ViewIDComponent<View, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  public typealias R = ViewIDRenderer<View, Content.R>
  let content: Content
  let id: String

  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).id(id)
  }
}

public struct ViewAnimatorComponent<View, Content: ViewComponent>: ViewComponent where Content.R.View == View {
  public typealias R = ViewAnimatorRenderer<View, Content.R>
  let content: Content
  let animator: Animator?

  public func layout(_ constraint: Constraint) -> R {
    content.layout(constraint).animator(animator)
  }
}

public extension ViewComponent {
  subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> ViewModifierComponent<R.View, Value, Self> {
    return { value in
      self.with(keyPath, value)
    }
  }
  func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewModifierComponent<R.View, Value, Self> {
    return ViewModifierComponent(content: self, keyPath: keyPath, value: value)
  }
  func id(_ id: String) -> ViewIDComponent<R.View, Self> {
    return ViewIDComponent(content: self, id: id)
  }
  func animator(_ animator: Animator?) -> ViewAnimatorComponent<R.View, Self> {
    return ViewAnimatorComponent(content: self, animator: animator)
  }
  func update(_ update: @escaping (R.View) -> Void) -> ViewUpdateComponent<R.View, Self> {
    return ViewUpdateComponent(content: self, update: update)
  }
}
