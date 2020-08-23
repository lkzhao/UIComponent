//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public protocol StackElement: Element, BaseLayoutProtocol {
  var spacing: CGFloat { get }
  var justifyContent: MainAxisAlignment { get }
  var alignItems: CrossAxisAlignment { get }
  var children: [Element] { get }
}

extension StackElement {
  public func layout(_ constraint: Constraint) -> Renderer {
    let renderers = getRenderers(constraint)
    let mainTotal = renderers.reduce(0) {
      $0 + main($1.size)
    }
    
    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: main(constraint.maxSize),
                                                               totalPrimary: mainTotal,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: renderers.count)
    
    var primaryOffset = offset
    var secondaryMax: CGFloat = 0
    var positions: [CGPoint] = []
    for child in renderers {
      positions.append(point(main: primaryOffset, cross: 0))
      primaryOffset += main(child.size) + distributedSpacing
      secondaryMax = max(cross(child.size), secondaryMax)
    }
    let finalSize = size(main: primaryOffset - distributedSpacing, cross: secondaryMax)

    return renderer(size: finalSize, children: renderers, positions: positions)
  }
  
  func getRenderers(_ constraint: Constraint) -> [Renderer] {
    var renderers: [Renderer?] = []
    
    let spacings = spacing * CGFloat(children.count - 1)
    var mainFreezed: CGFloat = spacings
    var flexCount: CGFloat = 0

    let childConstraint = Constraint(maxSize: constraint.maxSize,
                                     minSize: size(main: main(constraint.minSize),
                                                   cross: alignItems == .stretch ? cross(constraint.maxSize) : cross(constraint.minSize)))
    for child in children {
      if let flexChild = child as? FlexibleElement {
        flexCount += flexChild.flex
        renderers.append(nil)
      } else {
        let childRenderer = child.layout(childConstraint)
        mainFreezed += main(childRenderer.size)
        renderers.append(childRenderer)
      }
    }
    
    if flexCount > 0 {
      let mainMax = main(constraint.maxSize)
      let mainPerFlex = mainMax == .infinity ? 0 : max(0, mainMax - mainFreezed) / flexCount
      for (index, child) in children.enumerated() {
        if let child = child as? FlexibleElement {
          let mainReserved = mainPerFlex * child.flex
          let constraint = Constraint(maxSize: size(main: mainReserved, cross: cross(constraint.maxSize)),
                                      minSize: size(main: child.fit == .tight ? mainReserved : 0,
                                                    cross: alignItems == .stretch ? cross(constraint.maxSize) : 0))
          let renderer = child.layout(constraint)
          if child.fit == .loose {
            renderers[index] = SizeOverrideRenderer(child: renderer, size: size(main: mainReserved, cross: cross(renderer.size)))
          } else {
            renderers[index] = renderer
          }
          mainFreezed += mainReserved
        }
      }
    }

    return renderers.map { $0! }
  }
}

public struct RowElement: StackElement, VerticalLayoutProtocol {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Element]
}

public struct ColumnElement: StackElement, HorizontalLayoutProtocol {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Element]
}
