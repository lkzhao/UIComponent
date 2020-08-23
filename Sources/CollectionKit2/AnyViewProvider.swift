//
//  AnyViewProvider.swift
//  CollectionKit3
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol AnyViewProvider: Provider {
	/// A unique id for identifying self.
	var id: String { get }

	/// The animator used for layout animations.
	var animator: Animator? { get }

	/// Make a new view.
	func _makeView() -> UIView

	/// Update the dequeued view.
	func _updateView(_ view: UIView)

  /// retrieve size
  func sizeThatFits(_ size: CGSize) -> CGSize
}

extension AnyViewProvider {
  var animator: Animator? {
    return nil
  }

  // MARK: - modifier
  public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> AnyViewProvider {
    return SizeOverrideProvider(child: self, width: width, height: height)
  }
  public func size(width: CGFloat, height: SizeStrategy = .fit) -> AnyViewProvider {
    return SizeOverrideProvider(child: self, width: .absolute(width), height: height)
  }
  public func size(width: CGFloat, height: CGFloat) -> AnyViewProvider {
    return SizeOverrideProvider(child: self, width: .absolute(width), height: .absolute(height))
  }
  public func size(width: SizeStrategy = .fit, height: CGFloat) -> AnyViewProvider {
    return SizeOverrideProvider(child: self, width: width, height: .absolute(height))
  }
  public func size(_ sizeProvider: @escaping (CGSize) -> CGSize) -> AnyViewProvider {
    return SizeClosureProvider(child: self, sizeProvider: sizeProvider)
  }
}

extension AnyViewProvider {
  public func layout(size: CGSize) -> LayoutNode {
    return SingleLayoutNode(size: sizeThatFits(size), viewProvider: self)
  }
}

struct SingleLayoutNode: LayoutNode {
  let size: CGSize
  let viewProvider: AnyViewProvider
  
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    let childFrame = CGRect(origin: .zero, size: size)
    if frame.intersects(childFrame) {
      return [(viewProvider, childFrame)]
    }
    return []
  }
}

class SizeOverrideProvider: AnyViewProvider {
  var width: SizeStrategy
  var height: SizeStrategy
  var child: AnyViewProvider
  
  var id: String {
    return child.id
  }
  
  var animator: Animator? {
    return child.animator
  }
  
  init(child: AnyViewProvider, width: SizeStrategy, height: SizeStrategy) {
    self.child = child
    self.width = width
    self.height = height
  }
  
  func sizeThatFits(_ size: CGSize) -> CGSize {
    let fitSize: CGSize
    if width.isFit || height.isFit {
      fitSize = child.sizeThatFits(size)
    } else {
      fitSize = .zero
    }
    
    var result = CGSize.zero
    switch width {
    case .fill:
      // if parent width is infinity (un specified?)
      result.width = (size.width == .infinity ? fitSize.width : size.width)
    case .fit:
      result.width = fitSize.width
    case let .absolute(value):
      result.width = value
    }

    switch height {
    case .fill:
      result.height = size.height == .infinity ? fitSize.height : size.height
    case .fit:
      result.height = fitSize.height
    case let .absolute(value):
      result.height = value
    }

    return result
  }

  func _makeView() -> UIView {
    return child._makeView()
  }
  
  func _updateView(_ view: UIView) {
    child._updateView(view)
  }
}

class SizeClosureProvider: AnyViewProvider {
  var sizeProvider: (CGSize) -> CGSize
  var child: AnyViewProvider
  
  var id: String {
    return child.id
  }
  
  var animator: Animator? {
    return child.animator
  }
  
  init(child: AnyViewProvider, sizeProvider: @escaping (CGSize) -> CGSize) {
    self.child = child
    self.sizeProvider = sizeProvider
  }
  
  func sizeThatFits(_ size: CGSize) -> CGSize {
    return sizeProvider(size)
  }

  func _makeView() -> UIView {
    return child._makeView()
  }
  
  func _updateView(_ view: UIView) {
    child._updateView(view)
  }
}
