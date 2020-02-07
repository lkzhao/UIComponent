//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol ProviderDisplayable: class {
  var ckData: CKData { get }
}

public typealias ProviderDisplayableView = ProviderDisplayable & UIView

public extension ProviderDisplayable {
  var provider: Provider? {
    get { return ckData.provider }
    set { ckData.provider = newValue }
  }
  var animator: Animator {
    get { return ckData.animator }
    set { ckData.animator = newValue }
  }
  var reloadCount: Int {
    return ckData.reloadCount
  }
  var needsReload: Bool {
    return ckData.needsReload
  }
  var needsInvalidateLayout: Bool {
    return ckData.needsInvalidateLayout
  }
  var isLoadingCell: Bool {
    return ckData.isLoadingCell
  }
  var isReloading: Bool {
    return ckData.isReloading
  }
  var hasReloaded: Bool { reloadCount > 0 }

  var visibleCells: [UIView] {
    return ckData.visibleCells
  }
  var visibleViewData: [(AnyViewProvider, CGRect)] {
    return ckData.visibleViewData
  }
  var lastLoadBounds: CGRect {
    return ckData.lastLoadBounds
  }
  var contentOffsetChange: CGPoint {
    return ckData.contentOffsetChange
  }
  func setNeedsReload() {
    ckData.setNeedsReload()
  }
  func setNeedsInvalidateLayout() {
    ckData.setNeedsInvalidateLayout()
  }
  func setNeedsLoadCells() {
    ckData.setNeedsLoadCells()
  }
  func ensureZoomViewIsCentered() {
    ckData.ensureZoomViewIsCentered()
  }
  func invalidateLayout() {
    ckData.invalidateLayout()
  }
  func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    ckData.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
  }
}

extension ProviderDisplayable where Self: UIView {
  func cell(at point: CGPoint) -> UIView? {
    return visibleCells.first {
      $0.point(inside: $0.convert(point, from: self), with: nil)
    }
  }
}

public class CKData {
  public weak var view: ProviderDisplayableView?
  public var provider: Provider? {
    willSet {
      (provider as? ProgressiveProvider)?.onUpdate = nil
    }
    didSet {
      if let provider = provider as? ProgressiveProvider {
        provider.onUpdate = { [weak provider, weak self] newSize in
          guard let progressProvider = self?.provider as? ProgressiveProvider, provider === progressProvider else { return }
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
  public private(set) var visibleViewData: [(AnyViewProvider, CGRect)] = []

  public private(set) var lastLoadBounds: CGRect = .zero
  public private(set) var contentOffsetChange: CGPoint = .zero

  public var centerContentViewVertically = false
  public var centerContentViewHorizontally = true
  public var contentView: UIView? {
    didSet {
      oldValue?.removeFromSuperview()
      if let contentView = contentView {
        view?.addSubview(contentView)
      }
    }
  }
  public var contentSize: CGSize = .zero {
    didSet {
      (view as? UIScrollView)?.contentSize = contentSize
    }
  }
  public var contentOffset: CGPoint {
    get { return view?.bounds.origin ?? .zero }
    set { view?.bounds.origin = newValue }
  }
  public var contentInset: UIEdgeInsets {
    guard let view = view as? UIScrollView else { return .zero }
    return view.adjustedContentInset
  }
  public var bounds: CGRect {
    guard let view = view else { return .zero }
    return view.bounds
  }
  public var adjustedSize: CGSize {
    bounds.size.inset(by: contentInset)
  }
  public var zoomScale: CGFloat {
    guard let view = view as? UIScrollView else { return 1 }
    return view.zoomScale
  }

  private var visibleIdentifiers: [String] = []
  
  init(view: ProviderDisplayableView) {
    self.view = view
  }
  
  func layoutSubview() {
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
    boundsSize = bounds.inset(by: contentInset)
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
    view?.setNeedsLayout()
  }

  public func setNeedsInvalidateLayout() {
    needsInvalidateLayout = true
    view?.setNeedsLayout()
  }

  public func setNeedsLoadCells() {
    lastLoadBounds = .zero
    view?.setNeedsLayout()
  }

  // re-layout, but not updating cells' contents
  public func invalidateLayout() {
    guard let view = view, !isLoadingCell, !isReloading, hasReloaded, let provider = provider else { return }
    contentSize = provider.layout(size: adjustedSize)
    needsInvalidateLayout = false
    _loadCells(reloading: false)
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    guard let view = view, let provider = provider, !isReloading else { return }
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
    guard let view = view, !isLoadingCell, let provider = provider else { return }
    isLoadingCell = true
    defer {
      isLoadingCell = false
    }

    animator.willUpdate(collectionView: view)
    let visibleFrame = contentView?.convert(bounds, from: view) ?? bounds
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
      let cell = visibleCells[index]
      if let index = newIdentifierSet[identifier] {
        newCells[index] = cell
      } else {
        (visibleViewData[index].0.animator ?? animator)?.delete(collectionView: view,
                                                                view: cell)
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
          viewProvider._updateView(cell)
          (viewProvider.animator ?? animator).shift(collectionView: view,
                                                    delta: contentOffsetChange,
                                                    view: cell,
                                                    frame: frame)
        }
      } else {
        cell = viewProvider._makeView()
        viewProvider._updateView(cell)
        cell.bounds.size = frame.bounds.size
        cell.center = frame.center
        (viewProvider.animator ?? animator).insert(collectionView: view,
                                                   view: cell,
                                                   frame: frame)
        newCells[index] = cell
      }
      (viewProvider.animator ?? animator).update(collectionView: view,
                                                 view: cell,
                                                 frame: frame)
      (contentView ?? view).insertSubview(cell, at: index)
    }

    visibleIdentifiers = newIdentifiers
    visibleViewData = newVisibleViewData
    visibleCells = newCells as! [UIView]
    lastLoadBounds = bounds
  }

  open func sizeThatFits(_ size: CGSize) -> CGSize {
    return provider?.layout(size: size) ?? .zero
  }
}

open class CollectionView: UIScrollView, ProviderDisplayable {
  lazy public var ckData: CKData = CKData(view: self)
  
  public var contentView: UIView? {
    get { return ckData.contentView }
    set { ckData.contentView = newValue }
  }

	public convenience init(provider: Provider) {
		self.init()
		self.provider = provider
	}

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

	open override func layoutSubviews() {
		super.layoutSubviews()
    ckData.layoutSubview()
	}
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    ckData.sizeThatFits(size)
  }
}

open class CKView: UIView, ProviderDisplayable {
  lazy public var ckData: CKData = CKData(view: self)

  public convenience init(provider: Provider) {
    self.init()
    self.provider = provider
  }

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    ckData.layoutSubview()
  }
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    ckData.sizeThatFits(size)
  }
}
