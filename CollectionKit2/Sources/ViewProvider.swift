//
//  ViewProvider.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol ViewProvider: Provider {
  var key: String { get }
  var animator: Animator? { get }

  func construct() -> UIView

  /// Update the dequeud view
  func update(view: UIView)
}
