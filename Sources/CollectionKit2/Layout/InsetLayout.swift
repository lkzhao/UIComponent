//
//  InsetLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

/// A layout provider wraps another provider with insets.
public struct InsetLayout: Provider {
	public var insets: UIEdgeInsets
	public var child: Provider
	public var insetProvider: ((CGSize) -> UIEdgeInsets)?

	public init(insets: UIEdgeInsets = .zero, child: Provider) {
		self.insets = insets
		self.child = child
	}

	public init(insetProvider: @escaping (CGSize) -> UIEdgeInsets, child: Provider) {
		self.insetProvider = insetProvider
		self.insets = .zero
		self.child = child
	}

	public func layout(size: CGSize) -> LayoutNode {
    let insets = insetProvider?(size) ?? self.insets
		return InsetLayoutNode(insets: insets, child: child.layout(size: size.inset(by: insets)))
	}
}

struct InsetLayoutNode: LayoutNode {
  let insets: UIEdgeInsets
  let child: LayoutNode
  var size: CGSize {
    return child.size.inset(by: -insets)
  }
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    child.views(in: frame.inset(by: -insets)).map {
      ($0.0, $0.1 + CGPoint(x: insets.left, y: insets.top))
    }
  }
}
