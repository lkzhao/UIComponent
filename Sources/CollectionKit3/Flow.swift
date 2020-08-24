//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/24/20.
//

import UIKit

public struct Flow: Component, VerticalLayoutProtocol {
  public var lineSpacing: CGFloat
  public var interitemSpacing: CGFloat

  public var alignContent: MainAxisAlignment
  public var alignItems: CrossAxisAlignment
  public var justifyContent: MainAxisAlignment
  public var children: [Provider]

  public init(lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              alignContent: MainAxisAlignment = .start,
              children: [Provider]) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.alignContent = alignContent
    self.children = children
  }

  public init(spacing: CGFloat,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              alignContent: MainAxisAlignment = .start,
              children: [Provider]) {
    self.init(lineSpacing: spacing,
              interitemSpacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              alignContent: alignContent,
              children: children)
  }
  
  public func layout(_ constraint: Constraint) -> Renderer {
    let childConstraint = Constraint(minSize: .zero, maxSize: constraint.maxSize)
    var renderers: [Renderer] = children.map {
      $0.layout(childConstraint)
    }
    var positions: [CGPoint] = []
    
    var lineData: [(lineSize: CGSize, count: Int)] = []
    var currentLineItemCount = 0
    var currentLineWidth: CGFloat = 0
    var currentLineMaxHeight: CGFloat = 0
    var totalHeight: CGFloat = 0
    for renderer in renderers {
      if currentLineWidth + cross(renderer.size) > cross(constraint.maxSize), currentLineItemCount != 0 {
        lineData.append((lineSize: size(main: currentLineMaxHeight,
                                        cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing),
                         count: currentLineItemCount))
        totalHeight += currentLineMaxHeight
        currentLineMaxHeight = 0
        currentLineWidth = 0
        currentLineItemCount = 0
      }
      currentLineMaxHeight = max(currentLineMaxHeight, main(renderer.size))
      currentLineWidth += cross(renderer.size) + interitemSpacing
      currentLineItemCount += 1
    }
    if currentLineItemCount > 0 {
      lineData.append((lineSize: size(main: currentLineMaxHeight,
                                      cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing),
                       count: currentLineItemCount))
      totalHeight += currentLineMaxHeight
    }
    
    var (mainOffset, mainSpacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                            maxPrimary: main(constraint.maxSize),
                                                            totalPrimary: totalHeight,
                                                            minimunSpacing: lineSpacing,
                                                            numberOfItems: lineData.count)

    var index = 0
    for (lineSize, count) in lineData {
      var (crossOffset, crossSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                                maxPrimary: cross(constraint.maxSize),
                                                                totalPrimary: cross(lineSize),
                                                                minimunSpacing: interitemSpacing,
                                                                numberOfItems: count)

      for (itemIndex, var child) in renderers[index ..< (index + count)].enumerated() {
        if alignItems == .stretch, main(child.size) != main(lineSize) {
          // relayout items with a fixed main size
          child = children[index + itemIndex].layout(Constraint(minSize: size(main: main(lineSize), cross: 0),
                                                                maxSize: size(main: main(lineSize), cross: cross(constraint.maxSize))))
          renderers[index + itemIndex] = child
        }
        let alignValue: CGFloat
        switch alignItems {
        case .start, .stretch:
          alignValue = 0
        case .end:
          alignValue = main(lineSize) - main(child.size)
        case .center:
          alignValue = (main(lineSize) - main(child.size)) / 2
        }
        positions.append(point(main: mainOffset + alignValue, cross: crossOffset))
        crossOffset += cross(child.size) + crossSpacing
      }
  
      mainOffset += main(lineSize) + mainSpacing
      index += count
    }
    
    let finalSize = size(main: mainOffset - mainSpacing, cross: cross(constraint.maxSize))
    return renderer(size: finalSize, children: renderers, positions: positions)
  }
}


public extension Flow {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content().components)
  }
}

public extension Flow {
  init(lineSpacing: CGFloat = 0,
       interitemSpacing: CGFloat = 0,
       justifyContent: MainAxisAlignment = .start,
       alignItems: CrossAxisAlignment = .start,
       alignContent: MainAxisAlignment = .start,
       @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(lineSpacing: lineSpacing, interitemSpacing: interitemSpacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content().components)
  }
  init(spacing: CGFloat = 0,
       justifyContent: MainAxisAlignment = .start,
       alignItems: CrossAxisAlignment = .start,
       alignContent: MainAxisAlignment = .start,
       @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(spacing: spacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content().components)
  }
}
