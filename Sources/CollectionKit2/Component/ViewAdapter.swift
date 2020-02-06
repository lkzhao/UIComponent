//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

public protocol GenericValueHolder {
  func write(to: AnyObject)
}

open class ViewAdapter<View: UIView>: BaseViewProvider<View> {
  struct ValueHolder<Value>: GenericValueHolder {
    let keyPath: ReferenceWritableKeyPath<View, Value>
    let value: Value
    func write(to: AnyObject) {
      (to as! View)[keyPath: keyPath] = value
    }
  }
  var values: [GenericValueHolder] = []
  public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> Self {
    values.append(ValueHolder(keyPath: keyPath, value: value))
    return self
  }
  open override func updateView(_ view: View) {
    for value in values {
      value.write(to: view)
    }
  }
  public func backgroundColor(_ color: UIColor) -> Self {
    with(\.backgroundColor, color)
  }
}
