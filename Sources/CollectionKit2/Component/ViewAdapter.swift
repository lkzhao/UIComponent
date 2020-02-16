//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

protocol GenericValueHolder {
  func write(to: AnyObject) -> GenericValueHolder
}

open class ViewAdapter<View: UIView>: AnyViewProvider {
  struct ValueHolder<Value>: GenericValueHolder {
    let keyPath: ReferenceWritableKeyPath<View, Value>
    let value: Value
    func write(to: AnyObject) -> GenericValueHolder {
      let toView = (to as! View)
      let resetHolder = ValueHolder<Value>(keyPath: keyPath, value: toView[keyPath: keyPath])
      toView[keyPath: keyPath] = value
      return resetHolder
    }
  }

  // MARK: - Reuse
  open lazy var reuseKey: String? = NSStringFromClass(Self.self)

  // MARK: -
  private var values: [AnyKeyPath: GenericValueHolder] = [:]
  
  open var key: String
  open var animator: Animator?
  open var view: View?
  
  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              view: View? = nil) {
    self.key = key
    self.animator = animator
    self.view = view
  }
  
  open func makeView() -> View {
    return View()
  }
  
  open func updateView(_ view: View) {
    let context = view.ckContext
    for (k, v) in context.valueResets {
      if values[k] == nil {
        _ = v.write(to: view)
        context.valueResets[k] = nil
      }
    }
    for (keyPath, value) in values {
      let resetValueWriter = value.write(to: view)
      if context.valueResets[keyPath] == nil {
        context.valueResets[keyPath] = resetValueWriter
      }
    }
  }
  
  // MARK: - View Provider
  open func sizeThatFits(_ size: CGSize) -> CGSize {
    return view?.sizeThatFits(size) ?? .zero
  }
  
  public func _makeView() -> UIView {
    if let view = view {
      return view
    }
    if let reuseKey = reuseKey {
      return CollectionReuseManager.shared.dequeue(identifier: reuseKey, makeView())
    }
    return makeView()
  }
  
  public func _updateView(_ view: UIView) {
    guard let view = view as? View else { return }
    updateView(view)
  }
  
  // MARK: - modifiers

  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> Self {
    values[keyPath] = ValueHolder(keyPath: keyPath, value: value)
    return self
  }
  
  public func tintColor(_ tintColor: UIColor) -> Self {
    with(\.tintColor, tintColor)
  }

  public func backgroundColor(_ color: UIColor) -> Self {
    with(\.backgroundColor, color)
  }

  public func scaleAspectFit() -> Self {
    with(\.contentMode, .scaleAspectFit)
  }

  public func scaleAspectFill() -> Self {
    with(\.contentMode, .scaleAspectFill)
  }

  public func alignCenter() -> Self {
    with(\.contentMode, .center)
  }

  public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
    with(\.layer.cornerRadius, cornerRadius)
  }
  
  public func opacity(_ opacity: CGFloat) -> Self {
    with(\.alpha, opacity)
  }

  public func border(_ color: UIColor, width: CGFloat) -> Self {
    with(\.layer.borderColor, color.cgColor).with(\.layer.borderWidth, width)
  }
  
  public func shadow(color: UIColor = UIColor.black.withAlphaComponent(0.33), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> Self {
    with(\.layer.shadowColor, color.cgColor)
      .with(\.layer.shadowRadius, radius)
      .with(\.layer.shadowOffset, CGSize(width: x, height: y))
      .with(\.layer.shadowOpacity, 1)
  }
}

