//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol Provider: class {
  /// parent prodivder size
  func layout(size: CGSize) -> CGSize // self size, content size
  /// parent provider frame, visable frame in self's corrdinates.
  func views(in frame: CGRect) -> [(ViewProvider, CGRect)] // view frame in self's corrdinates
}


/// ProgressiveProvider
/// A Provider that can update its own `contentSize` at a future time.
///
/// A regular Provider usually does its layout when `layout(size:)`
/// is called. This is fine for small dataset, but for large dataset, doing a complete
/// layout cycle takes quite a bit of time. This blocks main thread, and
/// makes UI unresponsive.
///
/// What ProgressiveProvider can do is returning a temporary `contentSize` when `layout(size:)`
/// is called, then later update its CollectionView with a new `contentSize`.
///
/// Use cases that this enables:
/// * only layout enough cells to be displayed within the viewport, as the user scrolls
///   down more, layout more cells.
/// * background thread layout.
///
/// Implementing ProvissiveProvider is an advance usage and requires deep understanding of
/// layout logic. ProgressiveProvider has to be the root Provider of a CollectionView
/// in order to work. Use only when regular Provider doesn't meet the performance need
/// of your application. Checkout `InfiniteListProvider` in the example project for
/// a basic ProgressiveProvider implementation reference.
public protocol ProgressiveProvider: Provider {
  var onUpdate: ((CGSize) -> Void)? { get set }
}
