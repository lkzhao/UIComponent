//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@dynamicMemberLookup
public protocol ViewRenderer: AnyViewRenderer {
  associatedtype View: UIView
  var reuseKey: String? { get }
  func makeView() -> View
  func updateView(_ view: View)
}

public extension ViewRenderer {
  // MARK: Default
  var reuseKey: String? {
    "\(type(of: self))"
  }
  func makeView() -> View {
    View()
  }
  // MARK: AnyViewRenderer
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

extension ViewRenderer {
  subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Value>) -> (Value) -> ViewModifierRenderer<View, Value, Self> {
    { with(keyPath, $0) }
  }
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> ViewModifierRenderer<View, Value, Self> {
    ViewModifierRenderer(content: self, keyPath: keyPath, value: value)
  }
  public func id(_ id: String) -> ViewIDRenderer<View, Self> {
    ViewIDRenderer(content: self, id: id)
  }
  public func animator(_ animator: Animator?) -> ViewAnimatorRenderer<View, Self> {
    ViewAnimatorRenderer(content: self, animator: animator)
  }
  public func reuseKey(_ reuseKey: String?) -> ViewReuseKeyRenderer<View, Self> {
    ViewReuseKeyRenderer(content: self, reuseKey: reuseKey)
  }
  public func update(_ update: @escaping (View) -> Void) -> ViewUpdateRenderer<View, Self> {
    ViewUpdateRenderer(content: self, update: update)
  }
}
