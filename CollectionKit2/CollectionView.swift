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

  public private(set) var reloadCount = 0
  public private(set) var needsReload = true
  public private(set) var needsInvalidateLayout = false
  public private(set) var isLoadingCell = false
  public private(set) var isReloading = false
  public var hasReloaded: Bool { return reloadCount > 0 }

  // visible identifiers for cells on screen
  public private(set) var visibleCells: [UIView] = []
  public private(set) var visibleFrames: [CGRect] = []

  public private(set) var lastLoadBounds: CGRect = .zero
  public private(set) var contentOffsetChange: CGPoint = .zero

  public convenience init(provider: Provider) {
    self.init()
    self.provider = provider
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
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

  public func invalidateLayout() {
    guard !isLoadingCell && !isReloading && hasReloaded, let provider = provider else { return }
    contentSize = provider.layout(size: innerSize)
    needsInvalidateLayout = false
    loadCells()
  }

  /*
   * Update visibleCells & visibleIndexes according to scrollView's visibleFrame
   * load cells that move into the visibleFrame and recycles them when
   * they move out of the visibleFrame.
   */
  func loadCells() {
    guard !isLoadingCell && !isReloading && hasReloaded else { return }
    isLoadingCell = true

    _loadCells(forceReload: false)

    for cell in visibleCells {
//      let animator = cell.currentCollectionAnimator ?? self.animator
//      animator.update(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
    }

    lastLoadBounds = bounds
    isLoadingCell = false
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

    let oldVisibleCells = Set(visibleCells)
    _loadCells(forceReload: true)

    for (cell, frame) in zip(visibleCells, visibleFrames) {
//      cell.currentCollectionAnimator = cell.collectionAnimator ?? provider.animator(at: index)
//      let animator = cell.currentCollectionAnimator ?? self.animator
      if oldVisibleCells.contains(cell) {
        // cell was on screen before reload, need to update the view.
//        provider.update(view: cell, at: index)
//        animator.shift(collectionView: self, delta: contentOffsetChange, view: cell,
//                        at: index, frame: provider.frame(at: index))
      }
//      animator.update(collectionView: self, view: cell,
//                       at: index, frame: provider.frame(at: index))
    }

    lastLoadBounds = bounds
    needsInvalidateLayout = false
    needsReload = false
    reloadCount += 1
    isReloading = false
  }

  private func _loadCells(forceReload: Bool) {
    guard let provider = provider else { return }
    let newCells = provider.views(in: visibleFrame)

    // optimization: we assume that corresponding identifier for each index doesnt change unless forceReload is true.
//    guard forceReload ||
//      newCells.last != visibleCells.last ||
//      newCells != visibleCells else {
//      return
//    }

    var newVisibleCells = [UIView]()
    var newVisibleFrames = [CGRect]()

    for (c, f) in newCells {
      newVisibleCells.append(c)
      newVisibleFrames.append(f)
    }

    let newVisibleCellsSet = Set(newVisibleCells)

    for visibleCell in visibleCells where !newVisibleCellsSet.contains(visibleCell) {
      //        (cell.currentCollectionAnimator ?? animator)?.delete(collectionView: self, view: cell)
      visibleCell.removeFromSuperview()
    }

    for (index, cell) in newVisibleCells.enumerated() where subviews.get(index) !== cell {
      let frame = newVisibleFrames[index]
      cell.bounds.size = frame.bounds.size
      cell.center = frame.center
//      cell.currentCollectionAnimator = cell.collectionAnimator ?? provider.animator(at: index)
//      let animator = cell.currentCollectionAnimator ?? self.animator
//      animator.insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
      insertSubview(cell, at: index)
    }

    visibleFrames = newVisibleFrames
    visibleCells = newVisibleCells
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
