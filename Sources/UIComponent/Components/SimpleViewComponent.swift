//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct SimpleViewComponent<View: UIView>: ViewComponent {
  public let id: String
  public let view: View?
  public init(id: String? = nil, view: View? = nil) {
    self.id = id ?? (view != nil ? "UIView-\(view!.hashValue)" : UUID().uuidString)
    self.view = view
  }
  public func layout(_ constraint: Constraint) -> SimpleViewRenderer<View> {
    SimpleViewRenderer(id: id, size: (view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint), view: view)
  }
}

public struct SimpleViewRenderer<View: UIView>: ViewRenderer {
  public let id: String
  public let size: CGSize
  public let view: View?
  public var reuseKey: String? {
    return view == nil ? "\(type(of: self))" : nil
  }
  public init(id: String, size: CGSize, view: View? = nil) {
    self.id = id
    self.size = size
    self.view = view
  }
  public func makeView() -> View {
    view ?? View()
  }
  public func updateView(_ view: View) {
    
  }
}

extension UIView: ViewComponent {
  public func layout(_ constraint: Constraint) -> some ViewRenderer {
    SimpleViewRenderer(id: "UIView-\(hashValue)",size: sizeThatFits(constraint.maxSize).bound(to: constraint), view: self)
  }
}
