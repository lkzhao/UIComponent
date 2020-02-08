//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol LayoutNode {
  var size: CGSize { get }
  
  /// Get items' view and its rect within the frame in current provider's coordinates.
  /// - Parameter frame: Parent provider's visible frame in current provider's coordinates.
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)]
}

/// Provider provides its size and its items' views.
public protocol Provider: ProviderBuilderComponent {
  /// Get content size based on the parent's size.
  /// - Parameter size: Parent provider's content size.
  func layout(size: CGSize) -> LayoutNode
}

extension Provider {
  public func padding(_ amount: CGFloat) -> InsetLayout {
    return InsetLayout(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  public func view() -> CKViewProvider {
    return CKViewProvider(self)
  }
  public func scrollView() -> CKScrollViewProvider {
    return CKScrollViewProvider(self)
  }
  public func flex(_ weight: CGFloat = 1) -> Flex {
    return Flex(weight: weight, child: self)
  }
}

public protocol ProviderWrapper: Provider {
  var provider: Provider { get }
}

extension ProviderWrapper {
  public func layout(size: CGSize) -> LayoutNode {
    return provider.layout(size: size)
  }
}

open class CKViewProvider: ViewAdapter<CKView> {
  var provider: Provider
  public init(_ provider: Provider) {
    self.provider = provider
    super.init()
  }
  public override func updateView(_ view: CKView) {
    view.provider = provider
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return provider.layout(size: size).size
  }
}

open class CKScrollViewProvider: ViewAdapter<CollectionView> {
  var provider: Provider
  public init(_ provider: Provider) {
    self.provider = provider
    super.init()
  }
  public override func updateView(_ view: CollectionView) {
    view.provider = provider
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return provider.layout(size: size).size
  }
}
