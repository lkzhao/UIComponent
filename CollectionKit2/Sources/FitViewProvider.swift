//
//  FitViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class FitViewProvider: ViewProvider {

  public var key: String
  public var view: UIView
  public var animator: Animator?
  public var width: CGFloat?
  public var height: CGFloat?

  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              width: CGFloat? = nil,
              height: CGFloat? = nil,
              view: UIView) {
    self.key = key
    self.view = view
    self.animator = animator
    self.width = width
    self.height = height
  }
  public func construct() -> UIView {
    return view
  }
  public func update(view: UIView) {
  }

  var _size: CGSize = .zero
  public func layout(size: CGSize) -> CGSize {
    _size = view.sizeThatFits(size)
    if let width = width {
      _size.width = width
    }
    if let height = height {
      _size.height = height
    }
    return _size
  }

  public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return [(self, CGRect(origin: .zero, size: _size))]
  }
}
