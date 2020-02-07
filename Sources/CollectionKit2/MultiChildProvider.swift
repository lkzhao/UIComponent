//
//  MultiChildProvider.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import CoreGraphics.CGGeometry
import Foundation

open class MultiChildProvider: Provider {
	open var children: [Provider] = []

	public init(children: [Provider]) {
		self.children = children
	}

	open func layout(size _: CGSize) -> CGSize {
		fatalError("Subclass should provide the implementation.")
	}

	open func views(in _: CGRect) -> [(AnyViewProvider, CGRect)] {
		fatalError("Subclass should provide the implementation.")
	}
}
