//
//  ViewProvider.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol ViewProvider: Provider {
	/// A unique key for identifying self.
  var key: String { get }

	/// The animator used for layout animations.
  var animator: Animator? { get }

	/// Make a new view.
  func makeView() -> UIView

  /// Update the dequeued view.
  func updateView(_ view: UIView)
}
