//
//  SimpleViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class SimpleViewProvider: ViewProvider {

  public enum SizeStrategy {
    case fill, fit, absolute(CGFloat)
  }

  public var key: String
  public var view: UIView
  public var animator: Animator?
  public var width: SizeStrategy
  public var height: SizeStrategy
  public var sizeProvider: ((CGSize) -> CGSize)?

  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              width: SizeStrategy = .fit,
              height: SizeStrategy = .fit,
              view: UIView) {
    self.key = key
    self.view = view
    self.animator = animator
    self.width = width
    self.height = height
  }
  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              view: UIView,
              sizeProvider: @escaping (CGSize) -> CGSize) {
    self.key = key
    self.view = view
    self.animator = animator
    self.width = .fit
    self.height = .fit
    self.sizeProvider = sizeProvider
  }
  public func construct() -> UIView {
    return view
  }
  public func update(view: UIView) {
  }

  var _size: CGSize = .zero
  public func layout(size: CGSize) -> CGSize {
    if let sizeProvider = sizeProvider {
      _size = sizeProvider(size)
      return _size
    }
    let fitSize = view.sizeThatFits(size)
    switch width {
    case .fill:
      _size.width = size.width == .infinity ? fitSize.width : size.width
    case .fit:
      _size.width = fitSize.width
    case .absolute(let value):
      _size.width = value
    }
    switch height {
    case .fill:
      _size.height = size.height == .infinity ? fitSize.height : size.height
    case .fit:
      _size.height = fitSize.height
    case .absolute(let value):
      _size.height = value
    }
    return _size
  }

  public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return [(self, CGRect(origin: .zero, size: _size))]
  }
}
