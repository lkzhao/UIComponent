//
//  ClosureViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class ClosureViewProvider<View: UIView>: ViewProvider {

	public typealias ViewGenerator = () -> View
	public typealias ViewUpdater = (View) -> Void
	public typealias SizeGenerator = (CGSize) -> CGSize

	public var viewGenerator: ViewGenerator?
	public var viewUpdater: ViewUpdater?
	public var sizeSource: SizeGenerator?
	public var reuseManager: CollectionReuseManager?

	public init(key: String = UUID().uuidString,
							animator: Animator? = nil,
							reuseManager: CollectionReuseManager? = nil,
							generate: ViewGenerator? = nil,
							update: ViewUpdater?,
							size: SizeGenerator?) {
		self.key = key
		self.animator = animator
		self.reuseManager = reuseManager
		self.viewGenerator = generate
		self.viewUpdater = update
		self.sizeSource = size
	}

	// MARK: - ViewProvider

	public var key: String
	public var animator: Animator?

	public func makeView() -> UIView {
		return reuseManager?.dequeue(_makeView()) ?? _makeView()
	}

	public func updateView(_ view: UIView) {
		guard let view = view as? View else { return }
		viewUpdater?(view)
	}

	// MARK: - Provider

	public func layout(size: CGSize) -> CGSize {
		if let sizeSource = sizeSource {
			_size = sizeSource(size)
			return _size
		} else {
			return .zero
		}
	}

	public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
		let childFrame = CGRect(origin: .zero, size: _size)
		if frame.intersects(childFrame) {
			return [(self, childFrame)]
		}
		return []
	}

	// MARK: - Private

	private func _makeView() -> UIView {
		if let viewGenerator = viewGenerator {
			return viewGenerator()
		} else {
			return View()
		}
	}

	var _size: CGSize = .zero
}
