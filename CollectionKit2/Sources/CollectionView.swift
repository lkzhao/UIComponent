//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

open class CollectionView: UIScrollView {
	public var provider: Provider? {
		willSet {
			(provider as? ProgressiveProvider)?.onUpdate = nil
		}
		didSet {
			if let provider = provider as? ProgressiveProvider {
				provider.onUpdate = { [weak provider, weak self] newSize in
					guard provider === self?.provider else { return }
					self?.contentSize = newSize
					if self?.isLoadingCell == false {
						self?.setNeedsLoadCells()
					}
				}
			}
			setNeedsReload()
		}
	}

	public var animator: Animator = Animator() {
		didSet { setNeedsReload() }
	}

	public private(set) var reloadCount = 0
	public private(set) var needsReload = true
	public private(set) var needsInvalidateLayout = false
	public private(set) var isLoadingCell = false
	public private(set) var isReloading = false
	public var hasReloaded: Bool { reloadCount > 0 }

	// visible identifiers for cells on screen
	public private(set) var visibleCells: [UIView] = []
	public private(set) var visibleViewData: [(ViewProvider, CGRect)] = []

	public private(set) var lastLoadBounds: CGRect = .zero
	public private(set) var contentOffsetChange: CGPoint = .zero

	public var centerContentViewVertically = false
	public var centerContentViewHorizontally = true
	public var contentView: UIView? {
		didSet {
			oldValue?.removeFromSuperview()
			if let contentView = contentView {
				addSubview(contentView)
			}
		}
	}

	private var visibleIdentifiers: [String] = []

	public convenience init(provider: Provider) {
		self.init()
		self.provider = provider
	}

	open override func layoutSubviews() {
		super.layoutSubviews()
		if needsReload {
			reloadData()
		} else if needsInvalidateLayout || bounds.size != lastLoadBounds.size {
			invalidateLayout()
		} else if bounds != lastLoadBounds {
			_loadCells(reloading: false)
		}
		contentView?.frame = CGRect(origin: .zero, size: contentSize)
		ensureZoomViewIsCentered()
	}

	public func ensureZoomViewIsCentered() {
		guard let contentView = contentView else { return }
		let boundsSize: CGRect
		if #available(iOS 11.0, *) {
			boundsSize = bounds.inset(by: adjustedContentInset)
		} else {
			boundsSize = bounds.inset(by: contentInset)
		}
		var frameToCenter = contentView.frame

		if centerContentViewHorizontally, frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5
		} else {
			frameToCenter.origin.x = 0
		}

		if centerContentViewVertically, frameToCenter.size.height < boundsSize.height {
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5
		} else {
			frameToCenter.origin.y = 0
		}

		contentView.frame = frameToCenter
	}

	public func setNeedsReload() {
		needsReload = true
		setNeedsLayout()
	}

	public func setNeedsInvalidateLayout() {
		needsInvalidateLayout = true
		setNeedsLayout()
	}

	public func setNeedsLoadCells() {
		lastLoadBounds = .zero
		setNeedsLayout()
	}

	@available(iOS 11, *)
	open override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		setNeedsInvalidateLayout()
	}

	// re-layout, but not updating cells' contents
	public func invalidateLayout() {
		guard !isLoadingCell, !isReloading, hasReloaded, let provider = provider else { return }
		contentSize = provider.layout(size: adjustedSize)
		needsInvalidateLayout = false
		_loadCells(reloading: false)
	}

	// reload all frames. will automatically diff insertion & deletion
	public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
		guard let provider = provider, !isReloading else { return }
		isReloading = true
		defer {
			isReloading = false
		}

		contentSize = provider.layout(size: adjustedSize) * zoomScale

		let oldContentOffset = contentOffset
		if let offset = contentOffsetAdjustFn?() {
			contentOffset = offset
		}
		contentOffsetChange = contentOffset - oldContentOffset

		_loadCells(reloading: true)

		needsInvalidateLayout = false
		needsReload = false
		reloadCount += 1
	}

	private func _loadCells(reloading: Bool) {
		guard !isLoadingCell, let provider = provider else { return }
		isLoadingCell = true
		defer {
			isLoadingCell = false
		}

		animator.willUpdate(collectionView: self)
		let visibleFrame = contentView?.convert(bounds, from: self) ?? bounds
		let newVisibleViewData = provider.views(in: visibleFrame)

		// construct private identifiers
		var newIdentifierSet = [String: Int]()
		let newIdentifiers: [String] = newVisibleViewData.enumerated().map { index, viewData in
			let identifier = viewData.0.key
			var finalIdentifier = identifier
			var count = 1
			while newIdentifierSet[finalIdentifier] != nil {
				finalIdentifier = identifier + String(count)
				count += 1
			}
			newIdentifierSet[finalIdentifier] = index
			return finalIdentifier
		}

		var newCells = [UIView?](repeating: nil, count: newVisibleViewData.count)

		// 1st pass, delete all removed cells and move existing cells
		for index in 0 ..< visibleCells.count {
			let identifier = visibleIdentifiers[index]
			let view = visibleCells[index]
			if let index = newIdentifierSet[identifier] {
				newCells[index] = view
			} else {
				(visibleViewData[index].0.animator ?? animator)?.delete(collectionView: self,
																																view: view)
			}
		}

		// 2nd pass, insert new views
		for (index, viewData) in newVisibleViewData.enumerated() {
			let (viewProvider, frame) = viewData
			let cell: UIView
			if let existingCell = newCells[index] {
				cell = existingCell
				if reloading {
					// cell was on screen before reload, need to update the view.
					viewProvider.updateView(cell)
					(viewProvider.animator ?? animator).shift(collectionView: self,
																										delta: contentOffsetChange,
																										view: cell,
																										frame: frame)
				}
			} else {
				cell = viewProvider.makeView()
				viewProvider.updateView(cell)
				cell.bounds.size = frame.bounds.size
				cell.center = frame.center
				(viewProvider.animator ?? animator).insert(collectionView: self,
																									 view: cell,
																									 frame: frame)
				newCells[index] = cell
			}
			(viewProvider.animator ?? animator).update(collectionView: self,
																								 view: cell,
																								 frame: frame)
			(contentView ?? self).insertSubview(cell, at: index)
		}

		visibleIdentifiers = newIdentifiers
		visibleViewData = newVisibleViewData
		visibleCells = newCells as! [UIView]
		lastLoadBounds = bounds
	}

	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return provider?.layout(size: size) ?? .zero
	}
}

extension CollectionView {
	public func cell(at point: CGPoint) -> UIView? {
		return visibleCells.first {
			$0.point(inside: $0.convert(point, from: self), with: nil)
		}
	}
}
