//
//  FlexLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-02.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class Flex: SingleChildProvider {
  var flex: CGFloat

  init(flex: CGFloat = 1, child: Provider) {
    self.flex = flex
    super.init(child: child)
  }
}

public class FlexLayout: SortedLayoutProvider {
  public var spacing: CGFloat
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  /// always stretch filling item to fill empty space even if child returns a smaller size
  public var alwaysFillEmptySpaces: Bool = true

  public override var isImplementedInVertical: Bool {
    return false
  }

  public init(spacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              children: [Provider]) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    super.init(children: children)
  }

  public override func simpleLayout(size: CGSize) -> [CGRect] {
    let (sizes, totalWidth) = getCellSizes(size: size)

    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: size.width,
                                                               totalPrimary: totalWidth,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: children.count)

    let frames = LayoutHelper.alignItem(alignItems: alignItems,
                                        startingPrimaryOffset: offset, spacing: distributedSpacing,
                                        sizes: sizes, secondaryRange: 0...max(0, size.height))

    return frames
  }
}

extension FlexLayout {

  func getCellSizes(size: CGSize) -> (sizes: [CGSize], totalWidth: CGFloat) {
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
        let size = getSize(child: child, maxSize: size)
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
