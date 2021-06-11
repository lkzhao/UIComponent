//
//  ComponentDisplayable.swift
//  UIComponent
//
//  Created by Luke Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol ComponentDisplayableView: UIView {
  var engine: ComponentEngine { get }
}

public extension ComponentDisplayableView {
  var component: Component? {
    get { engine.component }
    set { engine.component = newValue }
  }
  var animator: Animator {
    get { engine.animator }
    set { engine.animator = newValue }
  }
  var visibleFrameInsets: UIEdgeInsets {
    get { engine.visibleFrameInsets }
    set { engine.visibleFrameInsets = newValue }
  }
  var reloadCount: Int {
    engine.reloadCount
  }
  var needsReload: Bool {
    engine.needsReload
  }
  var needsLoadCell: Bool {
    engine.needsLoadCell
  }
  var isLoadingCell: Bool {
    engine.isLoadingCell
  }
  var isReloading: Bool {
    engine.isReloading
  }
  var hasReloaded: Bool { reloadCount > 0 }

  var visibleCells: [UIView] {
    engine.visibleCells
  }
  var visibleViewData: [Renderable] {
    engine.visibleViewData
  }
  var lastLoadBounds: CGRect {
    engine.lastLoadBounds
  }
  var contentOffsetChange: CGPoint {
    engine.contentOffsetChange
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

extension ComponentDisplayableView {
  func cell(at point: CGPoint) -> UIView? {
    visibleCells.first {
      $0.point(inside: $0.convert(point, from: self), with: nil)
    }
  }
}
