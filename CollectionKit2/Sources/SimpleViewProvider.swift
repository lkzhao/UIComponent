//
//  SimpleViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//
import UIKit

/// A view provider provides a single view.
public class SimpleViewProvider: ViewProvider {
	public enum SizeStrategy {
		case fill, fit, absolute(CGFloat)
	}

	public var width: SizeStrategy
	public var height: SizeStrategy
	public var view: UIView
	public var sizeProvider: ((CGSize) -> CGSize)?

	public init(key: String = UUID().uuidString,
							animator: Animator? = nil,
							width: SizeStrategy = .fit,
							height: SizeStrategy = .fit,
							view: UIView) {
		self.key = key
		self.animator = animator
		self.width = width
		self.height = height
		self.view = view
	}

	public init(key: String = UUID().uuidString,
							animator: Animator? = nil,
							view: UIView,
							sizeProvider: @escaping (CGSize) -> CGSize) {
		self.key = key
		self.animator = animator
		self.width = .fit
		self.height = .fit
		self.view = view
		self.sizeProvider = sizeProvider
	}

	// MARK: - ViewProvider

	public var key: String
	public var animator: Animator?

	public func makeView() -> UIView {
		return view
	}

	public func updateView(_: UIView) {}

	// MARK: - Provider

	public func layout(size: CGSize) -> CGSize {
		if let sizeProvider = sizeProvider {
			_size = sizeProvider(size)
			return _size
		}

		let fitSize = view.sizeThatFits(size)
		switch width {
		case .fill:
			// if parent width is infinity (un specified?)
			_size.width = (size.width == .infinity ? fitSize.width : size.width)
		case .fit:
			_size.width = fitSize.width
		case let .absolute(value):
			_size.width = value
		}

		switch height {
		case .fill:
			_size.height = size.height == .infinity ? fitSize.height : size.height
		case .fit:
			_size.height = fitSize.height
		case let .absolute(value):
			_size.height = value
		}

		return _size
	}

	public func views(in _: CGRect) -> [(ViewProvider, CGRect)] {
		return [(self, CGRect(origin: .zero, size: _size))]
	}

	// MARK: - Private

	/// The content size of this provider.
	private var _size: CGSize = .zero
}
