//
//  UIScrollView+Addtion.swift
//  CollectionView
//
//  Created by Luke on 4/16/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

extension UIScrollView {
	public var visibleFrame: CGRect {
		return bounds
	}

	public var visibleFrameLessInset: CGRect {
		return visibleFrame.inset(by: contentInset)
	}

	public var offsetFrame: CGRect {
		let contentInset: UIEdgeInsets
		if #available(iOS 11.0, *) {
			contentInset = adjustedContentInset
		} else {
			contentInset = self.contentInset
		}
		return CGRect(x: -contentInset.left, y: -contentInset.top,
									width: max(0, contentSize.width - bounds.width + contentInset.right + contentInset.left),
									height: max(0, contentSize.height - bounds.height + contentInset.bottom + contentInset.top))
	}

	public func absoluteLocation(for point: CGPoint) -> CGPoint {
		return point - contentOffset
	}

	public func scrollTo(edge: UIRectEdge, animated: Bool) {
		let target: CGPoint
		switch edge {
		case UIRectEdge.top:
			target = CGPoint(x: contentOffset.x, y: offsetFrame.minY)
		case UIRectEdge.bottom:
			target = CGPoint(x: contentOffset.x, y: offsetFrame.maxY)
		case UIRectEdge.left:
			target = CGPoint(x: offsetFrame.minX, y: contentOffset.y)
		case UIRectEdge.right:
			target = CGPoint(x: offsetFrame.maxX, y: contentOffset.y)
		default:
			return
		}
		setContentOffset(target, animated: animated)
	}
}
