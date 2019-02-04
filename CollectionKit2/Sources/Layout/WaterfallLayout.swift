//
//  WaterfallLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class WaterfallLayout: SortedLayoutProvider {
  open var columns: Int
  open var spacing: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 2, spacing: CGFloat = 0, children: [Provider]) {
    self.columns = columns
    self.spacing = spacing
    super.init(children: children)
  }

  open override func simpleLayout(size: CGSize) -> [CGRect] {
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
      var cellSize = getSize(child: child, maxSize: CGSize(width: columnWidth, height: .infinity))
      cellSize = CGSize(width: columnWidth, height: cellSize.height)
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += cellSize.height + spacing
      let frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                         y: offsetY),
                         size: cellSize)
      frames.append(frame)
    }

    return frames
  }
}

open class HorizontalWaterfallLayout: WaterfallLayout {
  open override var isTransposed: Bool { return true }
}
