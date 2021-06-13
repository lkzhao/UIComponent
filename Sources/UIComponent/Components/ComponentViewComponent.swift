//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct ComponentDisplayableViewComponent<View: ComponentDisplayableView>: ViewComponent {
  let component: Component
  public init(component: Component) {
    self.component = component
  }
  public func layout(_ constraint: Constraint) -> ComponentDisplayableViewRenderer<View> {
    let renderer = component.layout(constraint)
    return ComponentDisplayableViewRenderer(size: renderer.size.bound(to: constraint),
                                            component: component,
                                            renderer: renderer)
  }
}

public struct ComponentDisplayableViewRenderer<View: ComponentDisplayableView>: ViewRenderer {
  public let size: CGSize
  public let component: Component
  public let renderer: Renderer
  public var id: String? {
    (renderer as? AnyViewRenderer)?.id ?? nil
  }
  public var keyPath: String {
    "\(type(of: self))." + ((renderer as? AnyViewRenderer)?.keyPath ?? "\(type(of: renderer))")
  }
  public func updateView(_ view: View) {
    view.engine.reloadWithExisting(component: component, renderer: renderer)
  }
}

public extension Component {
  func view() -> ComponentDisplayableViewComponent<ComponentView> {
    ComponentDisplayableViewComponent(component: self)
  }
  func scrollView() -> ComponentDisplayableViewComponent<ComponentScrollView> {
    ComponentDisplayableViewComponent(component: self)
  }
}

