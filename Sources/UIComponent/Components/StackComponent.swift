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
  public init(spacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              children: [Component] = []) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.children = children
  }
}

public struct VStack: StackComponent, VerticalLayoutProtocol {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
  public init(spacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              children: [Component] = []) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.children = children
  }
}

public extension HStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content())
  }
}

public extension VStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content())
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
    var renderers = getRenderers(constraint)
    let crossMax = renderers.reduce(CGFloat(0).clamp(cross(constraint.minSize), cross(constraint.maxSize))) {
      max($0, cross($1.size))
    }
    if cross(constraint.maxSize) == .infinity, alignItems == .stretch {
      // when using alignItem = .stretch, we need to relayout child to stretch its cross axis
      renderers = getRenderers(Constraint(minSize: constraint.minSize,
                                          maxSize: size(main: main(constraint.maxSize), cross: crossMax)))
    }
    let mainTotal = renderers.reduce(0) {
      $0 + main($1.size)
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
        crossValue = crossMax - cross(child.size)
      case .center:
        crossValue = (crossMax - cross(child.size)) / 2
      case .stretch:
        crossValue = 0
      }
      positions.append(point(main: primaryOffset, cross: crossValue))
      primaryOffset += main(child.size) + distributedSpacing
    }
    let finalSize = size(main: primaryOffset - distributedSpacing, cross: crossMax)

    return renderer(size: finalSize, children: renderers, positions: positions)
  }
  
  func getRenderers(_ constraint: Constraint) -> [Renderer] {
    var renderers: [Renderer?] = []
    
    let spacings = spacing * CGFloat(children.count - 1)
    var mainFreezed: CGFloat = spacings
    var flexCount: CGFloat = 0
    let crossMaxConstraint = cross(constraint.maxSize)

    let childConstraint = Constraint(minSize: size(main: -.infinity, cross: alignItems == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0),
                                     maxSize: size(main: .infinity, cross: cross(constraint.maxSize)))
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
          let constraint = Constraint(minSize: size(main: child.fit == .tight ? mainReserved : 0,
                                                    cross: alignItems == .stretch ? cross(constraint.maxSize) : 0),
                                      maxSize: size(main: mainReserved, cross: cross(constraint.maxSize)))
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
