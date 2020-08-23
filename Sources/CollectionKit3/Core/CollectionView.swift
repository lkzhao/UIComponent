//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol ComponentDisplayable: class {
  var engine: ComponentEngine { get }
}

public typealias ComponentDisplayableView = ComponentDisplayable & UIView

public extension ComponentDisplayable {
  var component: Component? {
    get { return engine.component }
    set { engine.component = newValue }
  }
  var animator: Animator {
    get { return engine.animator }
    set { engine.animator = newValue }
  }
  var reloadCount: Int {
    return engine.reloadCount
  }
  var needsReload: Bool {
    return engine.needsReload
  }
  var needsLoadCell: Bool {
    return engine.needsLoadCell
  }
  var isLoadingCell: Bool {
    return engine.isLoadingCell
  }
  var isReloading: Bool {
    return engine.isReloading
  }
  var hasReloaded: Bool { reloadCount > 0 }

  var visibleCells: [UIView] {
    return engine.visibleCells
  }
  var visibleViewData: [Renderable] {
    return engine.visibleViewData
  }
  var lastLoadBounds: CGRect {
    return engine.lastLoadBounds
  }
  var contentOffsetChange: CGPoint {
    return engine.contentOffsetChange
  }
  func setNeedsReload() {
    engine.setNeedsReload()
  }
  func setNeedsInvalidateLayout() {
    engine.setNeedsInvalidateLayout()
  }
  func setNeedsLoadCells() {
    engine.setNeedsLoadCells()
  }
  func ensureZoomViewIsCentered() {
    engine.ensureZoomViewIsCentered()
  }
  func invalidateLayout() {
    engine.invalidateLayout()
  }
  func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    engine.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
  }
}

extension ComponentDisplayable where Self: UIView {
  func cell(at point: CGPoint) -> UIView? {
    return visibleCells.first {
      $0.point(inside: $0.convert(point, from: self), with: nil)
    }
  }
}

public class ComponentEngine {
  public weak var view: ComponentDisplayableView?
  public var component: Component? {
    didSet {
      element = component?.build()
      setNeedsReload()
    }
  }
  public var element: Element?
  public var animator: Animator = Animator() {
    didSet { setNeedsReload() }
  }
  
  public private(set) var layoutNode: Renderer?
  
  public internal(set) var needsReload = true
  public internal(set) var needsLoadCell = false
  public private(set) var reloadCount = 0
  public private(set) var isLoadingCell = false
  public private(set) var isReloading = false
  public var hasReloaded: Bool { reloadCount > 0 }

  // visible identifiers for cells on screen
  public private(set) var visibleCells: [UIView] = []
  public private(set) var visibleViewData: [Renderable] = []

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
  private var shouldSkipLayout = false
  
  init(view: ComponentDisplayableView) {
    self.view = view
  }
  
  func layoutSubview() {
    if needsReload {
      reloadData()
    } else if bounds.size != lastLoadBounds.size {
      invalidateLayout()
    } else if bounds != lastLoadBounds || needsLoadCell {
      _loadCells()
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
    layoutNode = nil
    setNeedsLoadCells()
  }

  public func setNeedsLoadCells() {
    needsLoadCell = true
    view?.setNeedsLayout()
  }

  // re-layout, but not updating cells' contents
  public func invalidateLayout() {
    guard !isLoadingCell, !isReloading, hasReloaded else { return }
    layoutNode = nil
    _loadCells()
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    guard let element = element, !isReloading else { return }
    isReloading = true
    defer {
      needsReload = false
      isReloading = false
      shouldSkipLayout = false
    }

    if !shouldSkipLayout {
      layoutNode = element.layout(Constraint(maxSize: adjustedSize, minSize: .zero))
      contentSize = layoutNode!.size * zoomScale

      let oldContentOffset = contentOffset
      if let offset = contentOffsetAdjustFn?() {
        contentOffset = offset
      }
      contentOffsetChange = contentOffset - oldContentOffset
    }

    _loadCells()

    reloadCount += 1
  }

  private func _loadCells() {
    guard let view = view, !isLoadingCell, let element = element else { return }
    isLoadingCell = true
    defer {
      needsLoadCell = false
      isLoadingCell = false
    }
    
    let layoutNode: Renderer
    if let currentLayoutNode = self.layoutNode {
      layoutNode = currentLayoutNode
    } else {
      layoutNode = element.layout(Constraint(maxSize: adjustedSize, minSize: .zero))
      contentSize = layoutNode.size * zoomScale
      self.layoutNode = layoutNode
    }

    animator.willUpdate(collectionView: view)
    let visibleFrame = contentView?.convert(bounds, from: view) ?? bounds
    
    let newVisibleViewData = layoutNode.views(in: visibleFrame)
    if contentSize != layoutNode.size * zoomScale {
      // update contentSize if it is changed. Some layoutNodes update
      // its size when views(in: visibleFrame) is called. e.g. InfiniteLayout
      contentSize = layoutNode.size * zoomScale
    }

    // construct private identifiers
    var newIdentifierSet = [String: Int]()
    let newIdentifiers: [String] = newVisibleViewData.enumerated().map { index, viewData in
      let identifier = viewData.id
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
        (visibleViewData[index].animator ?? animator)?.delete(collectionView: view,
                                                              view: cell)
      }
    }

    // 2nd pass, insert new views
    for (index, viewData) in newVisibleViewData.enumerated() {
      let cell: UIView
      let frame = viewData.frame
      if let existingCell = newCells[index] {
        cell = existingCell
        if isReloading {
          // cell was on screen before reload, need to update the view.
          viewData.renderer._updateView(cell)
          (viewData.animator ?? animator).shift(collectionView: view,
                                                delta: contentOffsetChange,
                                                view: cell,
                                                frame: frame)
        }
      } else {
        cell = viewData.renderer._makeView()
        viewData.renderer._updateView(cell)
        UIView.performWithoutAnimation {
          cell.bounds.size = frame.bounds.size
          cell.center = frame.center
        }
        (viewData.animator ?? animator).insert(collectionView: view,
                                               view: cell,
                                               frame: frame)
        newCells[index] = cell
      }
      (viewData.animator ?? animator).update(collectionView: view,
                                             view: cell,
                                             frame: frame)
      (contentView ?? view).insertSubview(cell, at: index)
    }

    visibleIdentifiers = newIdentifiers
    visibleViewData = newVisibleViewData
    visibleCells = newCells as! [UIView]
    lastLoadBounds = bounds
  }
  
  // This function assigns component with an already calculated layoutNode
  // This is a performance hack that skips layout for the component if it has already
  // been layed out.
  internal func updateWithExisting(component: Component, layoutNode: Renderer?) {
    self.component = component
    self.layoutNode = layoutNode
    self.shouldSkipLayout = true
  }

  open func sizeThatFits(_ size: CGSize) -> CGSize {
    return layoutNode?.size ?? .zero
  }
}

open class CollectionView: UIScrollView, ComponentDisplayable {
  lazy public var engine: ComponentEngine = ComponentEngine(view: self)
  
  public var contentView: UIView? {
    get { return engine.contentView }
    set { engine.contentView = newValue }
  }

	public convenience init(component: Component) {
		self.init()
		self.component = component
	}

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

	open override func layoutSubviews() {
		super.layoutSubviews()
    engine.layoutSubview()
	}
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    engine.sizeThatFits(size)
  }
}

open class CKView: UIView, ComponentDisplayable {
  lazy public var engine: ComponentEngine = ComponentEngine(view: self)

  public convenience init(component: Component) {
    self.init()
    self.component = component
  }

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    engine.layoutSubview()
  }
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    engine.sizeThatFits(size)
  }
}
