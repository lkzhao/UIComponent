//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol Provider {
  /// parent prodivder size
  func layout(size: CGSize) -> CGSize // self size, content size
  /// parent provider frame, visable frame in self's corrdinates.
  func views(in frame: CGRect) -> [(ViewProvider, CGRect)] // view frame in self's corrdinates
}

public protocol ViewProvider: class, Provider {
  var key: String { get }
  var animator: Animator? { get }
  func construct() -> UIView //

  /// Update the dequeud view
  func update(view: UIView)
}
