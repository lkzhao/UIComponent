//
//  CollectionView+Extensions.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 2/1/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import UIKit

extension CollectionView {
	/// Adjusted size considering `adjustedContentInset`. Aka safe area size.
	public var adjustedSize: CGSize {
		bounds.size.inset(by: adjustedContentInset)
	}
}
