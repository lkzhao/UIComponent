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
    didSet { setNeedsReload() }
  }

  public var animator: Animator = Animator() {
    didSet { setNeedsReload() }
  }

  public private(set) var reloadCount = 0
  public private(set) var needsReload = true
  public private(set) var needsInvalidateLayout = false
  public private(set) var isLoadingCell = false
  public private(set) var isReloading = false
  public var hasReloaded: Bool { return reloadCount > 0 }

  // visible identifiers for cells on screen
  public private(set) var visibleCells: [UIView] = []
  public private(set) var visibleViewData: [(ViewProvider, CGRect)] = []

  public private(set) var lastLoadBounds: CGRect = .zero
  public private(set) var contentOffsetChange: CGPoint = .zero

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
      loadCells()
    }
  }

  public func setNeedsReload() {
    needsReload = true
    setNeedsLayout()
  }

  public func setNeedsInvalidateLayout() {
    needsInvalidateLayout = true
    setNeedsLayout()
  }

  // re-layout, but not updating cells' contents
  public func invalidateLayout() {
    guard !isLoadingCell && !isReloading && hasReloaded, let provider = provider else { return }
    contentSize = provider.layout(size: innerSize)
    needsInvalidateLayout = false
    loadCells()
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    guard let provider = provider, !isReloading else { return }
    isReloading = true

    let oldContentOffset = contentOffset
    contentSize = provider.layout(size: innerSize)
    if let offset = contentOffsetAdjustFn?() {
      contentOffset = offset
    }
    contentOffsetChange = contentOffset - oldContentOffset

    _loadCells(reloading: true)

    needsInvalidateLayout = false
    needsReload = false
    reloadCount += 1
    isReloading = false
  }

  /*
   * Update visibleCells according to scrollView's visibleFrame
   * load cells that move into the visibleFrame and recycles them when
   * they move out of the visibleFrame.
   */
  private func loadCells() {
    guard !isLoadingCell && !isReloading && hasReloaded else { return }
    isLoadingCell = true
    _loadCells(reloading: false)
    isLoadingCell = false
  }

  private func _loadCells(reloading: Bool) {
    guard let provider = provider else { return }
    let newVisibleViewData = provider.views(in: visibleFrame)

    // construct private identifiers
    var newIdentifierSet = [String: Int]()
    let newIdentifiers: [String] = newVisibleViewData.enumerated().map {
      let identifier = $1.0.key
      var finalIdentifier = identifier
      var count = 1
      while newIdentifierSet[finalIdentifier] != nil {
        finalIdentifier = identifier + "(\(count))"
        count += 1
      }
      newIdentifierSet[finalIdentifier] = $0
      return finalIdentifier
    }

    var newCells = Array<UIView>(repeating: self, count: newVisibleViewData.count)

    // 1st pass, delete all removed cells and move existing cells
    for index in 0..<visibleCells.count {
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
      if newCells[index] != self {
        cell = newCells[index]
        if reloading {
          // cell was on screen before reload, need to update the view.
          viewProvider.update(view: cell)
          (viewProvider.animator ?? animator).shift(collectionView: self,
                                                    delta: contentOffsetChange,
                                                    view: cell,
                                                    frame: frame)
        }
      } else {
        cell = (viewProvider.animator ?? animator).dequeue(viewProvider.construct())
        viewProvider.update(view: cell)
        (viewProvider.animator ?? animator).insert(collectionView: self,
                                                   view: cell,
                                                   frame: frame)
        newCells[index] = cell
      }
      (viewProvider.animator ?? animator).update(collectionView: self,
                                                 view: cell,
                                                 frame: frame)
      insertSubview(cell, at: index)
    }

    visibleIdentifiers = newIdentifiers
    visibleViewData = newVisibleViewData
    visibleCells = newCells
    lastLoadBounds = bounds
  }
}

extension CollectionView {
  public func cell(at point: CGPoint) -> UIView? {
    for cell in visibleCells {
      if cell.point(inside: cell.convert(point, from: self), with: nil) {
        return cell
      }
    }
    return nil
  }
}
