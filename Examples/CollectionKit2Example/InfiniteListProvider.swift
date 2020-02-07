//
//  InfiniteListProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 6/11/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import CollectionKit2
import UIKit

class InfiniteListProvider: ProgressiveProvider {
	var onUpdate: ((CGSize) -> Void)?

	var frames: [CGRect] = []
	var calculatedWidth: CGFloat = 0
	var calculatedHeight: CGFloat {
		return frames.last?.maxY ?? 0
	}

	func layoutUntil(height: CGFloat) {
		while calculatedHeight < height {
			let offsetY = calculatedHeight == 0 ? 0 : calculatedHeight + 4
			frames.append(CGRect(x: 0, y: offsetY, width: calculatedWidth, height: 40))
		}
	}

	func layout(size: CGSize) -> LayoutNode {
		if size.width != calculatedWidth {
			// clear calculated values
			calculatedWidth = size.width
			frames.removeAll()
		}

		layoutUntil(height: size.height * 2)
		return CGSize(width: calculatedWidth, height: calculatedHeight)
	}

	func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
		// Make sure this runs at least at O(log(n)) time, otherwise there is almost no benefit to use
		// ProgressiveProvider. Here, it is done using a binary search through the calculated frames

		if frame.maxY + frame.height > calculatedHeight {
			// need to leave some space for future scroll
			layoutUntil(height: frame.maxY + frame.height)

			// update the collectionView with new contentSize
			onUpdate?(CGSize(width: calculatedWidth, height: calculatedHeight))
		}

		var results = [Int]()
		var index = frames.binarySearch { $0.maxY < frame.minY }
		while let childFrame = frames.get(index), childFrame.minY < frame.maxY {
			results.append(index)
			index += 1
		}
		return results.map { index in
			let vp = ClosureViewProvider(key: "\(index)", update: { (view: UILabel) in
				view.text = "Item \(index)"
      }, size: nil)
			let frame = frames[index]
			return (vp, frame)
		}
	}
}

private extension Collection {
	/// Finds such index N that predicate is true for all elements up to
	/// but not including the index N, and is false for all elements
	/// starting with index N.
	/// Behavior is undefined if there is no such N.
	func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
		var low = startIndex
		var high = endIndex
		while low != high {
			let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
			if predicate(self[mid]) {
				low = index(after: mid)
			} else {
				high = mid
			}
		}
		return low
	}
}

private extension Array {
	func get(_ index: Int) -> Element? {
		if (0 ..< count).contains(index) {
			return self[index]
		}
		return nil
	}
}
