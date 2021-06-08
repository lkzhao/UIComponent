//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public protocol ComponentWrapperView: UIView {
  var wrappedComponentView: ComponentDisplayableView { get }
}

extension ComponentView: ComponentWrapperView {
  public var wrappedComponentView: ComponentDisplayableView { self }
}

extension ComponentScrollView: ComponentWrapperView {
  public var wrappedComponentView: ComponentDisplayableView { self }
}

public struct ComponentWrapperViewComponent<View: ComponentWrapperView>: ViewComponent {
  let id: String
  let component: Component
  public init(id: String, component: Component) {
    self.id = id
    self.component = component
  }
  public func layout(_ constraint: Constraint) -> ComponentWrapperViewRenderer<View> {
    let renderer = component.layout(constraint)
    return ComponentWrapperViewRenderer(id: id, size: renderer.size.bound(to: constraint), component: component, renderer: renderer)
  }
}

public struct ComponentWrapperViewRenderer<View: ComponentWrapperView>: ViewRenderer {
  public let id: String
  public let size: CGSize
  let component: Component
  let renderer: Renderer
  public func updateView(_ view: View) {
    view.wrappedComponentView.engine.updateWithExisting(component: component, renderer: renderer)
  }
}

public extension Component {
  func view(id: String = UUID().uuidString) -> ComponentWrapperViewComponent<ComponentView> {
    ComponentWrapperViewComponent(id: id, component: self)
  }
  func scrollView(id: String = UUID().uuidString) -> ComponentWrapperViewComponent<ComponentScrollView> {
    ComponentWrapperViewComponent(id: id, component: self)
  }
}

