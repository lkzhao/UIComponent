//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct ExistingViewComponent<View: UIView>: ViewComponent {
  public let view: View
  public init(view: View) {
    self.view = view
  }
  public func layout(_ constraint: Constraint) -> ExistingViewRenderer<View> {
    ExistingViewRenderer(size: view.sizeThatFits(constraint.maxSize).constraint(to: constraint), view: view)
  }
}

public struct ExistingViewRenderer<View: UIView>: ViewRenderer {
  public let id: String = UUID().uuidString
  public let size: CGSize
  public let view: UIView
  public func makeView() -> UIView {
    view
  }
  public func updateView(_ view: UIView) {
    
  }
}

extension UIView: ViewComponent {
  public func layout(_ constraint: Constraint) -> some ViewRenderer {
    ExistingViewRenderer(size: sizeThatFits(constraint.maxSize).constraint(to: constraint), view: self)
  }
}

public struct UIViewComponent: ViewComponent {
  public init() {}
  public func layout(_ constraint: Constraint) -> UIViewRenderer {
    UIViewRenderer(size: CGSize.zero.constraint(to: constraint))
  }
}

public struct UIViewRenderer: ViewRenderer {
  public let id: String = UUID().uuidString
  public let size: CGSize
  public func updateView(_ view: UIView) {}
}
