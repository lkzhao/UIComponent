//
//  FillViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class FillViewProvider: SimpleViewProvider {
	public init(
		key: String = UUID().uuidString,
		animator: Animator? = nil,
		width: CGFloat? = nil,
		height: CGFloat? = nil,
		view: UIView
	) {
		super.init(key: key, animator: animator,
							 width: width == nil ? .fill : .absolute(width!),
							 height: height == nil ? .fill : .absolute(height!),
							 view: view)
	}
}
