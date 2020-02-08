//
//  WaterfallLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public protocol WaterfallLayoutProtocol: LayoutProvider {
  var columns: Int { get }
  var spacing: CGFloat { get }
  var alignItems: AlignItem { get }
  var children: [Provider] { get }
}

extension WaterfallLayoutProtocol {
  public func simpleLayout(size: CGSize) -> ([LayoutNode], [CGRect]) {
    var nodes: [LayoutNode] = []
    var frames: [CGRect] = []

    let columnWidth = (size.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for child in children {
      let node = getLayoutNode(child: child, maxSize: CGSize(width: columnWidth, height: .infinity))
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += node.size.height + spacing

      let frame: CGRect
      switch alignItems {
      case .start:
        frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                       y: offsetY),
                       size: node.size)
      case .end:
        frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing) + columnWidth - node.size.width,
                                       y: offsetY),
                       size: node.size)
      case .center:
        frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing) + (columnWidth - node.size.width) / 2,
                                       y: offsetY),
                       size: node.size)
      case .stretch:
        frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                       y: offsetY),
                       size: CGSize(width: columnWidth, height: node.size.height))
      }
      nodes.append(node)
      frames.append(frame)
    }

    return (nodes, frames)
  }
}

public struct WaterfallLayout: LayoutProvider, WaterfallLayoutProtocol {
	public var columns: Int
	public var spacing: CGFloat
	public var alignItems: AlignItem
  public var children: [Provider]

	public init(columns: Int = 2, spacing: CGFloat = 0, alignItems: AlignItem = .start, children: [Provider]) {
		self.columns = columns
		self.spacing = spacing
		self.alignItems = alignItems
    self.children = children
	}
}

public struct HorizontalWaterfallLayout: LayoutProvider, WaterfallLayoutProtocol {
  public var columns: Int
  public var spacing: CGFloat
  public var alignItems: AlignItem
  public var children: [Provider]

  public init(columns: Int = 2, spacing: CGFloat = 0, alignItems: AlignItem = .start, children: [Provider]) {
    self.columns = columns
    self.spacing = spacing
    self.alignItems = alignItems
    self.children = children
  }

  public var isTransposed: Bool {
    return true
  }
}
