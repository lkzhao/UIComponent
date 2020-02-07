//
//  AnyViewProvider.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol AnyViewProvider: Provider {
	/// A unique key for identifying self.
	var key: String { get }

	/// The animator used for layout animations.
	var animator: Animator? { get }

	/// Make a new view.
	func _makeView() -> UIView

	/// Update the dequeued view.
	func _updateView(_ view: UIView)

  /// retrive view size
  func sizeThatFits(_ size: CGSize) -> CGSize
}

extension AnyViewProvider {
  // MARK: - modifier
  public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> AnyViewProvider {
    return SizeOverrideProvider(child: self, width: width, height: height)
  }
}

extension AnyViewProvider {
  public func layout(size: CGSize) -> CGSize {
    let size = sizeThatFits(size)
    ViewProviderSizeCache.shared.cache[key] = size
    return size
  }

  public func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    let childFrame = CGRect(origin: .zero, size: ViewProviderSizeCache.shared.cache[key] ?? .zero)
    if frame.intersects(childFrame) {
      return [(self, childFrame)]
    }
    return []
  }
}

class ViewProviderSizeCache {
  static let shared = ViewProviderSizeCache()
  var cache: [String: CGSize] = [:]
}
