//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/8/21.
//

import UIKit

open class TappableView: UIControl {
  public let ckView = ComponentView()
  public var onTap: ((TappableView) -> Void)?

  public override init(frame: CGRect) {
    super.init(frame: frame)
    accessibilityTraits = .button
    addSubview(ckView)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    ckView.frame = bounds
  }

  @objc open func didTap() {
    onTap?(self)
  }
}

public struct TappableViewComponent<View: TappableView>: ViewComponent {
  public let id: String
  public let onTap: ((TappableView) -> Void)?
  public let child: Component
  public func layout(_ constraint: Constraint) -> TappableViewRenderer<View> {
    let renderer = child.layout(constraint)
    return TappableViewRenderer(
      id: id, size: renderer.size.bound(to: constraint), component: child, renderer: renderer, onTap: onTap)
  }
}

public struct TappableViewRenderer<View: TappableView>: ViewRenderer {
  public let id: String
  public let size: CGSize
  public let component: Component
  public let renderer: Renderer
  public let onTap: ((TappableView) -> Void)?
  public func updateView(_ view: View) {
    view.ckView.engine.updateWithExisting(component: component, renderer: renderer)
    view.onTap = onTap
  }
}

extension Component {
  public func tappableView<V: TappableView>(id: String = UUID().uuidString, _ onTap: @escaping () -> Void) -> TappableViewComponent<V> {
    TappableViewComponent(id: id, onTap: { _ in onTap() }, child: self)
  }
  public func tappableView<V: TappableView>(id: String = UUID().uuidString, _ onTap: @escaping (TappableView) -> Void) -> TappableViewComponent<V> {
    TappableViewComponent(id: id, onTap: onTap, child: self)
  }
}
