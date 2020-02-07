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
  var values: [GenericValueHolder] = []
  
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

  public func backgroundColor(_ color: UIColor) -> Self {
    with(\.backgroundColor, color)
  }
}

class SizeOverrideProvider: AnyViewProvider {
  var width: SizeStrategy
  var height: SizeStrategy
  var child: AnyViewProvider
  
  var key: String {
    return child.key
  }
  
  var animator: Animator? {
    return child.animator
  }
  
  init(child: AnyViewProvider, width: SizeStrategy, height: SizeStrategy) {
    self.child = child
    self.width = width
    self.height = height
  }
  
  func sizeThatFits(_ size: CGSize) -> CGSize {
    let fitSize: CGSize
    if width.isFit || height.isFit {
      fitSize = child.sizeThatFits(size)
    } else {
      fitSize = .zero
    }
    
    var result = CGSize.zero
    switch width {
    case .fill:
      // if parent width is infinity (un specified?)
      result.width = (size.width == .infinity ? fitSize.width : size.width)
    case .fit:
      result.width = fitSize.width
    case let .absolute(value):
      result.width = value
    }

    switch height {
    case .fill:
      result.height = size.height == .infinity ? fitSize.height : size.height
    case .fit:
      result.height = fitSize.height
    case let .absolute(value):
      result.height = value
    }

    return result
  }

  func _makeView() -> UIView {
    return child._makeView()
  }
  
  func _updateView(_ view: UIView) {
    child._updateView(view)
  }
}
