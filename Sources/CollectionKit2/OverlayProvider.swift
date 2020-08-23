//
//  OverlayProvider.swift
//  CollectionKit3
//
//  Created by Luke Zhao on 2/3/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

/// A provider composed with doubly layered providers.
open class OverlayProvider: Provider {
	open var back: Provider
	open var front: Provider

	public init(back: Provider, front: Provider) {
		self.back = back
		self.front = front
	}

	open func layout(size: CGSize) -> LayoutNode {
		let frontNode = front.layout(size: size)
    let backNode = back.layout(size: frontNode.size)
    return OverlayLayoutNode(front: frontNode, back: backNode, size: frontNode.size)
	}
}

struct OverlayLayoutNode: LayoutNode {
  let front: LayoutNode
  let back: LayoutNode
  let size: CGSize
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    back.views(in: frame) + front.views(in: frame)
  }
}
