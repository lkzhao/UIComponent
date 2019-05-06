//
//  FlexLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-02.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class Flex: SingleChildProvider {
  public var flex: CGFloat

  public init(flex: CGFloat = 1, child: Provider) {
    self.flex = flex
    super.init(child: child)
  }
}

open class FlexLayout: SortedLayoutProvider {
  open var spacing: CGFloat
  open var alignItems: AlignItem
  open var justifyContent: JustifyContent

  open var fitCrossAxis: Bool

  /// always stretch filling item to fill empty space even if child returns a smaller size
  open var alwaysFillEmptySpaces: Bool = true

  /// whether or not we pass the parent maxSize down to the children for layout
  open var passThroughParentSize: Bool = false

  open override var isImplementedInVertical: Bool {
    return false
  }

  public init(spacing: CGFloat = 0,
              fitCrossAxis: Bool = false, // false -> fill
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              children: [Provider]) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.fitCrossAxis = fitCrossAxis
    super.init(children: children)
  }

  open override func simpleLayoutWithCustomSize(size: CGSize) -> ([CGRect], CGSize) {
    let (sizes, totalWidth) = getCellSizes(size: size)

    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: size.width,
                                                               totalPrimary: totalWidth,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: children.count)

    var upperBound = size.height
    if fitCrossAxis || upperBound == .infinity {
      upperBound = sizes.max(by: { (a, b) in
        a.height < b.height
      })?.height ?? 0
    }

    return LayoutHelper.alignItem(alignItems: alignItems,
                                  startingPrimaryOffset: offset, spacing: distributedSpacing,
                                  sizes: sizes, secondaryRange: 0...max(0, upperBound))
  }

  open func getCellSizes(size: CGSize) -> (sizes: [CGSize], totalWidth: CGFloat) {
    var sizes: [CGSize] = []
    let spacings = spacing * CGFloat(children.count - 1)
    var freezedWidth = spacings
    var fillIndexes: [Int] = []
    var totalFlex: CGFloat = 0

    for (i, child) in children.enumerated() {
      if let child = child as? Flex {
        totalFlex += child.flex
        fillIndexes.append(i)
        sizes.append(.zero)
      } else {
        let size = getSize(child: child, maxSize: CGSize(width: passThroughParentSize ? size.width : .infinity,
                                                         height: size.height))
        sizes.append(size)
        freezedWidth += size.width
      }
    }

    let widthPerFlex: CGFloat = max(0, size.width - freezedWidth) / max(totalFlex, 1)
    for i in fillIndexes {
      let child = children[i] as! Flex
      let size = getSize(child: child, maxSize: CGSize(width: widthPerFlex * child.flex,
                                                       height: size.height))
      let width = alwaysFillEmptySpaces ? max(widthPerFlex, size.width) : size.width
      sizes[i] = CGSize(width: width, height: size.height)
      freezedWidth += sizes[i].width
    }

    return (sizes, freezedWidth - spacings)
  }
}

public typealias RowLayout = FlexLayout

open class ColumnLayout: FlexLayout {
  open override var isTransposed: Bool { return true }
}
