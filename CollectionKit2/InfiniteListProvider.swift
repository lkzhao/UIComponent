//
//  InfiniteListProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 6/11/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

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

	func layout(size: CGSize) -> CGSize {
		if size.width != calculatedWidth {
			// clear calculated values
			calculatedWidth = size.width
			frames.removeAll()
		}

		layoutUntil(height: size.height * 2)
		return CGSize(width: calculatedWidth, height: calculatedHeight)
	}

	func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
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
