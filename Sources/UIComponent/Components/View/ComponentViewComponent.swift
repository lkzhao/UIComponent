//  Created by Luke Zhao on 8/23/20.

import UIKit

/**
 # ComponentViewComponent
 
 Wraps a `component` inside a `ComponentDisplayableView`.
 
 This is used to power the `.view()` and `.scrollView()` modifiers.
*/
public struct ComponentViewComponent<View: ComponentDisplayableView>: ViewComponent {
  let component: Component
  public init(component: Component) {
    self.component = component
  }
  public func layout(_ constraint: Constraint) -> ComponentViewRenderer<View> {
    let renderer = component.layout(constraint)
    return ComponentViewRenderer(size: renderer.size.bound(to: constraint), component: component, renderer: renderer)
  }
}

/// Renderer for the `ComponentViewComponent`
public struct ComponentViewRenderer<View: ComponentDisplayableView>: ViewRenderer {
  public let size: CGSize
  public let component: Component
  public let renderer: Renderer
  
  private var viewRenderer: AnyViewRenderer? {
    renderer as? AnyViewRenderer
  }
  public var id: String? {
    viewRenderer?.id
  }
  public var reuseKey: String? {
    viewRenderer?.reuseKey
  }
  public var animator: Animator? {
    viewRenderer?.animator
  }
  public var keyPath: String {
    "\(type(of: self))." + (viewRenderer?.keyPath ?? "\(type(of: renderer))")
  }
  public func updateView(_ view: View) {
    view.engine.reloadWithExisting(component: component, renderer: renderer)
  }
}

