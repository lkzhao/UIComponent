//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct HStack: StackComponent, HorizontalLayoutProtocol {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
}

public struct VStack: StackComponent, VerticalLayoutProtocol {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
}

public extension HStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content().components)
  }
}

public extension VStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content().components)
  }
}

public protocol StackComponent: Component, BaseLayoutProtocol {
  var spacing: CGFloat { get }
  var justifyContent: MainAxisAlignment { get }
  var alignItems: CrossAxisAlignment { get }
  var children: [Component] { get }
}

extension StackComponent {
  public func layout(_ constraint: Constraint) -> Renderer {
    let renderers = getRenderers(constraint)
    let mainTotal = renderers.reduce(0) {
      $0 + main($1.size)
    }
    let secondaryMax = renderers.reduce(0) {
      max($0, cross($1.size))
    }
    
    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: main(constraint.maxSize),
                                                               totalPrimary: mainTotal,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: renderers.count)
    
    var primaryOffset = offset
    var positions: [CGPoint] = []
    for child in renderers {
      let crossValue: CGFloat
      switch alignItems {
      case .start:
        crossValue = 0
      case .end:
        crossValue = secondaryMax - cross(child.size)
      case .center:
        crossValue = (secondaryMax - cross(child.size)) / 2
      case .stretch:
        crossValue = 0
      }
      positions.append(point(main: primaryOffset, cross: crossValue))
      primaryOffset += main(child.size) + distributedSpacing
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
                                     minSize: size(main: 0, cross: alignItems == .stretch ? cross(constraint.maxSize) : cross(constraint.minSize)))
    for child in children {
      if let flexChild = child as? Flexible {
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
        if let child = child as? Flexible {
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
