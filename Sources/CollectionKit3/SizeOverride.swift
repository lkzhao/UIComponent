//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public enum SizeStrategy {
  case fill, fit, absolute(CGFloat), percentage(CGFloat)
  var isFit: Bool {
    switch self {
    case .fit:
      return true
    default:
      return false
    }
  }
}

protocol ConstraintTransformer {
  func calculate(_ constraint: Constraint) -> Constraint
}

struct BlockConstraintTransformer: ConstraintTransformer {
  let block: (Constraint) -> Constraint
  func calculate(_ constraint: Constraint) -> Constraint {
    block(constraint)
  }
}

struct SizeStrategyConstraintTransformer: ConstraintTransformer {
  let width: SizeStrategy
  let height: SizeStrategy
  func calculate(_ constraint: Constraint) -> Constraint {
    var maxSize = constraint.maxSize
    var minSize = constraint.minSize
    switch width {
    case .fill:
      if maxSize.width != .infinity {
        minSize.width = maxSize.width
      }
    case .fit:
      break
    case .absolute(let value):
      assert(value >= 0, "absolute value should be 0...")
      maxSize.width = value
      minSize.width = value
    case .percentage(let value):
      assert(value <= 1 && value >= 0, "percentage value should be 0...1")
      if maxSize.width != .infinity {
        maxSize.width = value * maxSize.width
        minSize.width = value * maxSize.width
      }
    }
    switch height {
    case .fill:
      if maxSize.height != .infinity {
        minSize.height = maxSize.height
      }
    case .fit:
      break
    case .absolute(let value):
      assert(value >= 0, "absolute value should be 0...")
      maxSize.height = value
      minSize.height = value
    case .percentage(let value):
      assert(value <= 1 && value >= 0, "percentage value should be 0...1")
      if maxSize.height != .infinity {
        maxSize.height = value * maxSize.height
        minSize.height = value * maxSize.height
      }
    }
    return Constraint(minSize: minSize, maxSize: maxSize)
  }
}

struct SizeOverrideRenderer: Renderer {
  let child: Renderer
  let size: CGSize
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame)
  }
}

struct ConstraintOverrideComponent: Component {
  let child: Component
  let transformer: ConstraintTransformer
  func layout(_ constraint: Constraint) -> Renderer {
    child.layout(transformer.calculate(constraint))
  }
}

public struct ConstraintOverrideViewComponent<R, Content: ViewComponent>: ViewComponent where R == Content.R {
  let child: Content
  let transformer: ConstraintTransformer
  public func layout(_ constraint: Constraint) -> R {
    child.layout(transformer.calculate(constraint))
  }
}

public extension Component {
  func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
  }
  func size(width: CGFloat, height: SizeStrategy = .fit) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
  }
  func size(width: CGFloat, height: CGFloat) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
  }
  func size(width: SizeStrategy = .fit, height: CGFloat) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
  }
  func size(_ constraintProvider: @escaping (Constraint) -> Constraint) -> Component {
    ConstraintOverrideComponent(child: self, transformer: BlockConstraintTransformer(block: constraintProvider))
  }
}

public extension ViewComponent {
  func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
  }
  func size(width: CGFloat, height: SizeStrategy = .fit) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
  }
  func size(width: CGFloat, height: CGFloat) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
  }
  func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
  }
  func size(_ constraintProvider: @escaping (Constraint) -> Constraint) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: BlockConstraintTransformer(block: constraintProvider))
  }
}
