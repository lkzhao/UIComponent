//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol Provider {
  func layout(size: CGSize) -> CGSize
  func views(in frame: CGRect) -> [(ViewProvider, CGRect)]
}

public protocol ViewProvider: class, Provider {
  var key: String { get }
  var animator: Animator? { get }
  func construct() -> UIView
  func update(view: UIView)
}

open class MultiChildProvider: Provider {
  open var children: [Provider] = []
  public init(children: [Provider]) {
    self.children = children
  }
  open func layout(size: CGSize) -> CGSize {
    return .zero
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return []
  }
}

open class SingleChildProvider: Provider {
  open var child: Provider
  public init(child: Provider) {
    self.child = child
  }
  open func layout(size: CGSize) -> CGSize {
    return child.layout(size: size)
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return child.views(in: frame)
  }
}
