//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

protocol GenericValueHolder {
  func write(to: AnyObject)
}

open class ViewAdapter<View: UIView>: AnyViewProvider {
  struct ValueHolder<Value>: GenericValueHolder {
    let keyPath: ReferenceWritableKeyPath<View, Value>
    let value: Value
    func write(to: AnyObject) {
      (to as! View)[keyPath: keyPath] = value
    }
  }
  
  private var values: [GenericValueHolder] = []
  public var key: String
  public var animator: Animator?
  public var reuseManager: CollectionReuseManager?
  public var view: View?
  
  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              reuseManager: CollectionReuseManager? = nil,
              view: View? = nil) {
    self.key = key
    self.animator = animator
    self.reuseManager = reuseManager
    self.view = view
  }
  
  open func makeView() -> View {
    return view ?? View()
  }
  
  open func updateView(_ view: View) {
    for value in values {
      value.write(to: view)
    }
  }
  
  // MARK: - View Provider
  open func sizeThatFits(_ size: CGSize) -> CGSize {
    return view?.sizeThatFits(size) ?? .zero
  }
  
  public func _makeView() -> UIView {
    return reuseManager?.dequeue(makeView()) ?? makeView()
  }
  
  public func _updateView(_ view: UIView) {
    guard let view = view as? View else { return }
    updateView(view)
  }
  
  // MARK: - modifiers

  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> Self {
    values.append(ValueHolder(keyPath: keyPath, value: value))
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
