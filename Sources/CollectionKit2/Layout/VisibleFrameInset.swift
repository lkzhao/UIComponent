//
//  VisibleFrameInset.swift
//  CollectionKit3
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public struct VisibleFrameInset: Provider {
	public var insets: UIEdgeInsets
	public var insetProvider: ((CGSize) -> UIEdgeInsets)?
  public let child: Provider

	public init(insets: UIEdgeInsets = .zero, child: Provider) {
		self.insets = insets
    self.insetProvider = nil
    self.child = child
	}

	public init(insetProvider: @escaping ((CGSize) -> UIEdgeInsets), child: Provider) {
		self.insets = .zero
		self.insetProvider = insetProvider
    self.child = child
	}

	public func layout(size: CGSize) -> LayoutNode {
		return VisibleFrameInsetLayoutNode(insets: insets, insetProvider: insetProvider, child: child.layout(size: size))
	}
}

struct VisibleFrameInsetLayoutNode: LayoutNode {
  let insets: UIEdgeInsets
  let insetProvider: ((CGSize) -> UIEdgeInsets)?
  let child: LayoutNode
  var size: CGSize {
    return child.size
  }
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    let insets: UIEdgeInsets
    if let insetProvider = insetProvider {
      insets = insetProvider(size)
    } else {
      insets = self.insets
    }
    return child.views(in: frame.inset(by: insets))
  }
}
