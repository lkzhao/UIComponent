//
//  VisibleFrameInset.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class VisibleFrameInset: SingleChildProvider {
	public var insets: UIEdgeInsets
	public var insetProvider: ((CGSize) -> UIEdgeInsets)?
	private var layoutSize: CGSize = .zero

	public init(insets: UIEdgeInsets = .zero, child: Provider) {
		self.insets = insets
		super.init(child: child)
	}

	public init(insetProvider: @escaping ((CGSize) -> UIEdgeInsets), child: Provider) {
		self.insets = .zero
		self.insetProvider = insetProvider
		super.init(child: child)
	}

	open override func layout(size: CGSize) -> CGSize {
		layoutSize = size
		return super.layout(size: size)
	}

	open override func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
		if let insetProvider = insetProvider {
			insets = insetProvider(layoutSize)
		}
		return child.views(in: frame.inset(by: insets))
	}
}
