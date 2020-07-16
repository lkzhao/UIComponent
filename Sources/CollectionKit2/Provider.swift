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
  public func insets(_ amount: CGFloat) -> InsetLayout {
    return InsetLayout(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  public func insets(h: CGFloat = 0, v: CGFloat = 0) -> InsetLayout {
    return InsetLayout(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  public func insets(_ insets: UIEdgeInsets) -> InsetLayout {
    return InsetLayout(insets: insets, child: self)
  }
  public func insets(_ insetProvider: @escaping (CGSize) -> UIEdgeInsets) -> InsetLayout {
    return InsetLayout(insetProvider: insetProvider, child: self)
  }
  public func view(id: String = UUID().uuidString) -> ProviderDisplayableViewAdapter<CKView> {
    return ProviderDisplayableViewAdapter<CKView>(id: id, provider: self)
  }
  public func scrollView(id: String = UUID().uuidString) -> ProviderDisplayableViewAdapter<CollectionView> {
    return ProviderDisplayableViewAdapter<CollectionView>(id: id, provider: self)
  }
  public func flex(_ weight: CGFloat = 1) -> Flex {
    return Flex(weight: weight, child: self)
  }
  public func visibleInset(_ amount: CGFloat) -> VisibleFrameInset {
    return VisibleFrameInset(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  public func visibleInset(h: CGFloat = 0, v: CGFloat = 0) -> VisibleFrameInset {
    return VisibleFrameInset(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  public func visibleInset(_ insets: UIEdgeInsets) -> VisibleFrameInset {
    return VisibleFrameInset(insets: insets, child: self)
  }
  public func visibleInset(_ insetProvider: @escaping (CGSize) -> UIEdgeInsets) -> VisibleFrameInset {
    return VisibleFrameInset(insetProvider: insetProvider, child: self)
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

open class ProviderDisplayableViewAdapter<View: UIView & ProviderDisplayable>: ViewAdapter<View> {
  open var provider: Provider
  var cachedLayoutNode: LayoutNode?
  public init(id: String = UUID().uuidString, provider: Provider) {
    self.provider = provider
    super.init(id: id)
  }
  open override func updateView(_ view: View) {
    view.ckData.updateWithExisting(provider: provider, layoutNode: cachedLayoutNode)
    super.updateView(view)
  }
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    let layoutNode = provider.layout(size: size)
    cachedLayoutNode = layoutNode
    return layoutNode.size
  }
}
