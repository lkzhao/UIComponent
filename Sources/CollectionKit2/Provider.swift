//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

/// Provider provides its size and its items' views.
public protocol Provider: AnyObject, ProviderBuilderComponent {
  /// Get content size based on the parent's size.
  /// - Parameter size: Parent provider's content size.
  func layout(size: CGSize) -> CGSize
  
  /// Get items' view and its rect within the frame in current provider's coordinates.
  /// - Parameter frame: Parent provider's visible frame in current provider's coordinates.
  func views(in frame: CGRect) -> [(ViewProvider, CGRect)]
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
/// Implementing ProgressiveProvider is an advance usage and requires deep understanding of
/// layout logic. ProgressiveProvider has to be the root Provider of a CollectionView
/// in order to work. Use only when regular Provider doesn't meet the performance need
/// of your application. Checkout `InfiniteListProvider` in the example project for
/// a basic ProgressiveProvider implementation reference.
public protocol ProgressiveProvider: Provider {
  var onUpdate: ((CGSize) -> Void)? { get set }
}

extension Provider {
  public func padding(_ amount: CGFloat) -> InsetLayout {
    return InsetLayout(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  public func wrap() -> CKViewProvider {
    return CKViewProvider(self)
  }
  public func flex(_ weight: CGFloat = 1) -> Flex {
    return Flex(weight: weight, child: self)
  }
}

open class CKViewProvider: ViewAdapter<CKView> {
  var provider: Provider
  public init(_ provider: Provider) {
    self.provider = provider
    super.init()
  }
  public override func updateView(_ view: CKView) {
    if view.provider !== provider {
      view.provider = provider
    }
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return provider.layout(size: size)
  }
}
