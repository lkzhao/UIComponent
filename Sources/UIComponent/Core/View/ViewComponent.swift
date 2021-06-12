//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

@dynamicMemberLookup
public protocol ViewComponent: Component {
  associatedtype R: ViewRenderer
  func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
  public func layout(_ constraint: Constraint) -> Renderer {
    layout(constraint) as R
  }
}

public struct ViewModifierComponent<View, Content: ViewComponent, Result: ViewRenderer>: ViewComponent where Content.R.View == View, Result.View == View {
  let content: Content
  let modifier: (Content.R) -> Result

  public func layout(_ constraint: Constraint) -> Result {
    modifier(content.layout(constraint))
  }
}

public extension ViewComponent {
  subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> ViewModifierComponent<R.View, Self, ViewModifierRenderer<R.View, Value, R>> {
    { with(keyPath, $0) }
  }
  func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewModifierComponent<R.View, Self, ViewModifierRenderer<R.View, Value, R>> {
    ViewModifierComponent(content: self) {
      $0.with(keyPath, value)
    }
  }
  func id(_ id: String) -> ViewModifierComponent<R.View, Self, ViewIDRenderer<R.View, R>> {
    ViewModifierComponent(content: self) {
      $0.id(id)
    }
  }
  func animator(_ animator: Animator?) -> ViewModifierComponent<R.View, Self, ViewAnimatorRenderer<R.View, R>> {
    ViewModifierComponent(content: self) {
      $0.animator(animator)
    }
  }
  func reuseKey(_ reuseKey: String?) -> ViewModifierComponent<R.View, Self, ViewReuseKeyRenderer<R.View, R>> {
    ViewModifierComponent(content: self) {
      $0.reuseKey(reuseKey)
    }
  }
  func update(_ update: @escaping (R.View) -> Void) -> ViewModifierComponent<R.View, Self, ViewUpdateRenderer<R.View, R>> {
    ViewModifierComponent(content: self) {
      $0.update(update)
    }
  }
}
