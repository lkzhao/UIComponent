//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public protocol WaterfallLayoutProtocol: Component, BaseLayoutProtocol {
  var columns: Int { get }
  var spacing: CGFloat { get }
  var children: [Component] { get }
}

public extension WaterfallLayoutProtocol {
  func layout(_ constraint: Constraint) -> Renderer {
    var renderers: [Renderer] = []
    var positions: [CGPoint] = []

    let columnWidth = (cross(constraint.maxSize) - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for child in children {
      let renderer = child.layout(Constraint(minSize: size(main: 0, cross: columnWidth),
                                             maxSize: size(main: .infinity, cross: columnWidth)))
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += main(renderer.size) + spacing
      renderers.append(renderer)
      positions.append(point(main: offsetY, cross: CGFloat(columnIndex) * (columnWidth + spacing)))
    }

    return renderer(size: size(main: columnHeight.max()!, cross: cross(constraint.maxSize)),
                    children: renderers,
                    positions: positions)
  }
}

public struct Waterfall: WaterfallLayoutProtocol, VerticalLayoutProtocol {
  public var columns: Int
  public var spacing: CGFloat
  public var children: [Component]
  public init(columns: Int = 2, spacing: CGFloat = 0, children: [Component] = []) {
    self.columns = columns
    self.spacing = spacing
    self.children = children
  }
}

public struct HorizontalWaterfall: WaterfallLayoutProtocol, HorizontalLayoutProtocol {
  public var columns: Int
  public var spacing: CGFloat
  public var children: [Component]
  public init(columns: Int = 2, spacing: CGFloat = 0, children: [Component] = []) {
    self.columns = columns
    self.spacing = spacing
    self.children = children
  }
}

public extension Waterfall {
  init(columns: Int = 2, spacing: CGFloat = 0, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(columns: columns, spacing: spacing, children: content().components)
  }
}

public extension HorizontalWaterfall {
  init(columns: Int = 2, spacing: CGFloat = 0, @ComponentFunctionBuilder _ content: () -> ComponentFunctionBuilderItem) {
    self.init(columns: columns, spacing: spacing, children: content().components)
  }
}
