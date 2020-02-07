//
//  StickyLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-31.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class Sticky: SingleChildProvider {
	override init(child: Provider) {
		super.init(child: child)
	}
}

open class StickyHStack: HStack {
	private var stickyIndexes: [Int] = []

	open override func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
		var result = [(AnyViewProvider, CGRect)]()

		let topFrameIndex: Int
		if isTransposed {
			topFrameIndex = stickyIndexes.binarySearch { frames[$0].minY < frame.minY } - 1
		} else {
			topFrameIndex = stickyIndexes.binarySearch { frames[$0].minX < frame.minX } - 1
		}
		let stickyIndex = stickyIndexes.get(topFrameIndex)

		// add views from non-sticky children
		for index in visibleIndexes(in: frame) where index != stickyIndex {
			let child = children[index]
			let childFrame = frames[index]
			let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
				($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
			}
			result.append(contentsOf: childResult)
		}

		// now add views from sticky header on top, sticking to the edge
		if let stickyIndex = stickyIndex, stickyIndex >= 0 {
			let stickyChildFrame = frames[stickyIndex]
			let pushedPosition: CGPoint
			if isTransposed {
				if let nextStickyIndex = stickyIndexes.get(topFrameIndex + 1) {
					pushedPosition = CGPoint(x: stickyChildFrame.origin.x,
																	 y: min(frame.minY, frames[nextStickyIndex].minY - stickyChildFrame.height))
				} else {
					pushedPosition = CGPoint(x: stickyChildFrame.origin.x,
																	 y: min(frame.minY, frame.maxY - stickyChildFrame.height))
				}
			} else {
				if let nextStickyIndex = stickyIndexes.get(topFrameIndex + 1) {
					pushedPosition = CGPoint(x: min(frame.minX, frames[nextStickyIndex].minX - stickyChildFrame.width),
																	 y: stickyChildFrame.origin.y)
				} else {
					pushedPosition = CGPoint(x: min(frame.minX, frame.maxX - stickyChildFrame.width),
																	 y: stickyChildFrame.origin.y)
				}
			}
			let adjustedFrame = stickyChildFrame - stickyChildFrame.origin + pushedPosition
			let stickyChildResult = children[stickyIndex].views(in: frame.intersection(adjustedFrame) - pushedPosition).map {
				($0.0, CGRect(origin: $0.1.origin + pushedPosition, size: $0.1.size))
			}
			result.append(contentsOf: stickyChildResult)
		}

		return result
	}

	open override func layout(size: CGSize) -> LayoutNode {
		let size = super.layout(size: size)
		stickyIndexes = children.enumerated().filter { $0.element is Sticky }.map { $0.offset }
		return size
	}
}

open class StickyVStack: StickyHStack {
	open override var isTransposed: Bool { return true }
}
