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
  public let generator: (() -> View)?
  private init(id: String, view: View?, generator: (() -> View)?) {
    self.id = id
    self.view = view
    self.generator = generator
  }
  public init(id: String? = nil, view: View? = nil) {
    self.init(id: id ?? (view != nil ? "UIView-\(view!.hashValue)" : UUID().uuidString), view: view, generator: nil)
  }
  public init(id: String? = nil, generator: @autoclosure @escaping () -> View) {
    self.init(id: id ?? UUID().uuidString, view: nil, generator: generator)
  }
  public func layout(_ constraint: Constraint) -> SimpleViewRenderer<View> {
    SimpleViewRenderer(id: id, size: (view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint), view: view, generator: generator)
  }
}

public struct SimpleViewRenderer<View: UIView>: ViewRenderer {
  public let id: String
  public let size: CGSize
  public let view: View?
  public let generator: (() -> View)?
  public var reuseKey: String? {
    return view == nil ? "\(type(of: self))" : nil
  }
  
  fileprivate init(id: String, size: CGSize, view: View?, generator: (() -> View)?) {
    self.id = id
    self.size = size
    self.view = view
    self.generator = generator
  }
  
  public init(id: String, size: CGSize) {
    self.init(id: id, size: size, view: nil, generator: nil)
  }

  public init(id: String, size: CGSize, view: View) {
    self.init(id: id, size: size, view: view, generator: nil)
  }

  public init(id: String, size: CGSize, generator: @escaping (() -> View)) {
    self.init(id: id, size: size, view: nil, generator: generator)
  }

  public func makeView() -> View {
    if let view = view {
      return view
    } else if let generator = generator {
      return generator()
    } else {
      return View()
    }
  }

  public func updateView(_ view: View) {}
}

extension UIView: ViewComponent {
  public func layout(_ constraint: Constraint) -> some ViewRenderer {
    SimpleViewRenderer(id: "UIView-\(hashValue)", size: sizeThatFits(constraint.maxSize).bound(to: constraint), view: self)
  }
}
