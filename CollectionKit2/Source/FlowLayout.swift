//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout: SortedLayoutProvider {
  public var lineSpacing: CGFloat
  public var interitemSpacing: CGFloat

  public var alignContent: AlignContent
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  public init(lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              alignContent: AlignContent = .start,
              children: [Provider]) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.alignContent = alignContent
    super.init(children: children)
  }

  public convenience init(spacing: CGFloat,
                          justifyContent: JustifyContent = .start,
                          alignItems: AlignItem = .start,
                          alignContent: AlignContent = .start,
                          children: [Provider]) {
    self.init(lineSpacing: spacing,
              interitemSpacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              alignContent: alignContent,
              children: children)
  }

  public override func simpleLayout(size: CGSize) -> [CGRect] {
    var frames: [CGRect] = []

    let sizes = children.map { getSize(child: $0, maxSize: size) }
    let (totalHeight, lineData) = distributeLines(sizes: sizes, maxWidth: size.width)

    var (yOffset, spacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                     maxPrimary: size.height,
                                                     totalPrimary: totalHeight,
                                                     minimunSpacing: lineSpacing,
                                                     numberOfItems: lineData.count)

    var index = 0
    for (lineSize, count) in lineData {
      let (xOffset, lineInteritemSpacing) =
        LayoutHelper.distribute(justifyContent: justifyContent,
                                maxPrimary: size.width,
                                totalPrimary: lineSize.width,
                                minimunSpacing: interitemSpacing,
                                numberOfItems: count)

      let lineFrames = LayoutHelper.alignItem(alignItems: alignItems,
                                              startingPrimaryOffset: xOffset,
                                              spacing: lineInteritemSpacing,
                                              sizes: sizes[index..<(index+count)],
                                              secondaryRange: yOffset...(yOffset + lineSize.height))

      frames.append(contentsOf: lineFrames)

      yOffset += lineSize.height + spacing
      index += count
    }

    return frames
  }

  func distributeLines(sizes: [CGSize], maxWidth: CGFloat) ->
    (totalHeight: CGFloat, lineData: [(lineSize: CGSize, count: Int)]) {
      var lineData: [(lineSize: CGSize, count: Int)] = []
      var currentLineItemCount = 0
      var currentLineWidth: CGFloat = 0
      var currentLineMaxHeight: CGFloat = 0
      var totalHeight: CGFloat = 0
      for size in sizes {
        if currentLineWidth + size.width > maxWidth, currentLineItemCount != 0 {
          lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                            height: currentLineMaxHeight),
                           count: currentLineItemCount))
          totalHeight += currentLineMaxHeight
          currentLineMaxHeight = 0
          currentLineWidth = 0
          currentLineItemCount = 0
        }
        currentLineMaxHeight = max(currentLineMaxHeight, size.height)
        currentLineWidth += size.width + interitemSpacing
        currentLineItemCount += 1
      }
      if currentLineItemCount > 0 {
        lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                          height: currentLineMaxHeight),
                         count: currentLineItemCount))
        totalHeight += currentLineMaxHeight
      }
      return (totalHeight, lineData)
  }
}
