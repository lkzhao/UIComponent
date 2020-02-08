//
//  SpaceProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

/// A provider for spacing.
public class SpaceProvider: Provider {
	public var width: CGFloat
	public var height: CGFloat
	public init(width: CGFloat = 0,
				height: CGFloat = 0) {
		self.width = width
		self.height = height
	}

	public func layout(size _: CGSize) -> LayoutNode {
    return SpaceLayoutNode(size: CGSize(width: width, height: height))
	}
}

struct SpaceLayoutNode: LayoutNode {
  let size: CGSize
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    return []
  }
}

public class VSpace: Provider {
  public var height: CGFloat
  public init(_ height: CGFloat) {
    self.height = height
  }
  public func layout(size _: CGSize) -> LayoutNode {
    return SpaceLayoutNode(size: CGSize(width: 0, height: height))
  }
}

public class HSpace: Provider {
  public var width: CGFloat
  public init(_ width: CGFloat) {
    self.width = width
  }
  public func layout(size _: CGSize) -> LayoutNode {
    return SpaceLayoutNode(size: CGSize(width: width, height: 0))
  }
}
