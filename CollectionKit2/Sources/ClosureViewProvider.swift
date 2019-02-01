//
//  ClosureViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class ClosureViewProvider<View: UIView>: ViewProvider {
  public var key: String

  public typealias ViewGenerator = () -> View
  public typealias ViewUpdater = (View) -> Void
  public typealias SizeGenerator = (CGSize) -> CGSize

  public var animator: Animator?
  public var viewGenerator: ViewGenerator?
  public var viewUpdater: ViewUpdater?
  public var sizeSource: SizeGenerator?

  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              generate: ViewGenerator? = nil,
              update: ViewUpdater?,
              size: SizeGenerator?) {
    self.key = key
    self.animator = animator
    self.viewUpdater = update
    self.viewGenerator = generate
    self.sizeSource = size
  }

  public func construct() -> UIView {
    if let viewGenerator = viewGenerator {
      return viewGenerator()
    } else {
      return View()
    }
  }

  public func update(view: UIView) {
    guard let view = view as? View else { return }
    viewUpdater?(view)
  }

  var _size: CGSize = .zero
  public func layout(size: CGSize) -> CGSize {
    if let sizeSource = sizeSource {
      _size = sizeSource(size)
      return _size
    } else {
      return .zero
    }
  }

  public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    let childFrame = CGRect(origin: .zero, size: _size)
    if frame.intersects(childFrame) {
        return [(self, childFrame)]
    }
    return []
  }
}

