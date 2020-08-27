//
//  ComponentDisplayable.swift
//  UIComponent
//
//  Created by Luke Zhao on 2016-02-12.
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
