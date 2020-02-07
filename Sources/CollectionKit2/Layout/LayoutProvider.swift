//
//  LayoutProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class LayoutProvider: MultiChildProvider {
	public private(set) var frames: [CGRect] = []
	open var isTransposed: Bool { return false }

	open func simpleLayout(size _: CGSize) -> [CGRect] {
		fatalError("Subclass should provide its own layout")
	}

	open func simpleLayoutWithCustomSize(size: CGSize) -> ([CGRect], CGSize) {
		let frames = simpleLayout(size: size)
		let contentSize = frames.reduce(CGRect.zero) { old, item in
			old.union(item)
		}.size
		return (frames, contentSize)
	}

	open func doneLayout() {}

	open func getSize(child: Provider, maxSize: CGSize) -> CGSize {
		let size: CGSize
		if isTransposed {
			size = child.layout(size: maxSize.transposed).transposed
		} else {
			size = child.layout(size: maxSize)
		}
		assert(size.width.isFinite, "\(child)'s width is invalid")
		assert(size.height.isFinite, "\(child)'s height is invalid")
		return size
	}

	open override func layout(size: CGSize) -> CGSize {
		let contentSize: CGSize
		if isTransposed {
			let (_frames, _contentSize) = simpleLayoutWithCustomSize(size: size.transposed)
			frames = _frames.map { $0.transposed }
			contentSize = _contentSize.transposed
		} else {
			let (_frames, _contentSize) = simpleLayoutWithCustomSize(size: size)
			frames = _frames
			contentSize = _contentSize
		}
		doneLayout()
		return contentSize
	}

	open override func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
		var result = [(AnyViewProvider, CGRect)]()

		for (i, childFrame) in frames.enumerated() where frame.intersects(childFrame) {
			let child = children[i]
			let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map { viewProvider, frame in
				(viewProvider, CGRect(origin: frame.origin + childFrame.origin, size: frame.size))
			}
			result.append(contentsOf: childResult)
		}

		return result
	}
}
