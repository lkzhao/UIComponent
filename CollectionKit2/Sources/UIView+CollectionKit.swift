//
//  UIView+CollectionKit.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

extension UIView {
	private struct AssociatedKeys {
		static var reuseManager = "reuseManager"
	}

	internal var reuseManager: CollectionReuseManager? {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.reuseManager) as? CollectionReuseManager }
		set { objc_setAssociatedObject(self, &AssociatedKeys.reuseManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	public func recycleForCollectionKitReuse() {
		if let reuseManager = reuseManager {
			reuseManager.queue(view: self)
		} else {
			removeFromSuperview()
		}
	}
}
