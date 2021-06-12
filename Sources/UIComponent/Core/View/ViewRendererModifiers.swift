//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct ViewUpdateRenderer<View, Content: ViewRenderer>: ViewRenderer where Content.View == View {
  let content: Content
  let update: (View) -> Void
  
  public var id: String {
    content.id
  }
  public var reuseKey: String? {
    content.reuseKey
  }
  public var animator: Animator? {
    content.animator
  }
  public var size: CGSize {
    content.size
  }
  public func updateView(_ view: View) {
    content.updateView(view)
    update(view)
  }
  public func makeView() -> View {
    content.makeView()
  }
}

public struct ViewModifierRenderer<View, Value, Content: ViewRenderer>: ViewRenderer where Content.View == View {
  let content: Content
  let keyPath: ReferenceWritableKeyPath<View, Value>
  let value: Value
  
  public var id: String {
    content.id
  }
  public var reuseKey: String? {
    content.reuseKey
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

public struct ViewIDRenderer<View, Content: ViewRenderer>: ViewRenderer where Content.View == View {
  let content: Content
  public let id: String
  
  public var reuseKey: String? {
    content.reuseKey
  }
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

public struct ViewAnimatorRenderer<View, Content: ViewRenderer>: ViewRenderer where Content.View == View {
  let content: Content
  public let animator: Animator?
  public var id: String {
    content.id
  }
  public var reuseKey: String? {
    content.reuseKey
  }
  public var size: CGSize {
    content.size
  }
  public func updateView(_ view: View) {
    content.updateView(view)
  }
  public func makeView() -> View {
    content.makeView()
  }
}

public struct ViewReuseKeyRenderer<View, Content: ViewRenderer>: ViewRenderer where Content.View == View {
  let content: Content
  public let reuseKey: String?
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
  }
  public func makeView() -> View {
    content.makeView()
  }
}
