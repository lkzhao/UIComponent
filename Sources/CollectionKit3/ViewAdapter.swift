//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct ComponentDisplayableViewComponent<View: ComponentDisplayableView>: ViewComponent {
  let id: String
  let component: Component
  public func layout(_ constraint: Constraint) -> ComponentDisplayableViewRenderer<View> {
    let renderer = component.layout(constraint)
    return ComponentDisplayableViewRenderer(id: id, size: renderer.size.constraint(to: constraint), component: component, renderer: renderer)
  }
}

public struct ComponentDisplayableViewRenderer<View: ComponentDisplayableView>: ViewRenderer {
  public let id: String
  public let size: CGSize
  let component: Component
  let renderer: Renderer
  public func updateView(_ view: View) {
    view.engine.updateWithExisting(component: component, renderer: renderer)
  }
}

public extension Component {
  func view(id: String = UUID().uuidString) -> ComponentDisplayableViewComponent<CKView> {
    return ComponentDisplayableViewComponent<CKView>(id: id, component: self)
  }
  func scrollView(id: String = UUID().uuidString) -> ComponentDisplayableViewComponent<CollectionView> {
    return ComponentDisplayableViewComponent<CollectionView>(id: id, component: self)
  }
}
