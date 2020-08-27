//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public enum SizeStrategy {
  case fill, fit, absolute(CGFloat), percentage(CGFloat), aspectPercentage(CGFloat)
}

public protocol ConstraintTransformer {
  func calculate(_ constraint: Constraint) -> Constraint
}

struct BlockConstraintTransformer: ConstraintTransformer {
  let block: (Constraint) -> Constraint
  func calculate(_ constraint: Constraint) -> Constraint {
    block(constraint)
  }
}

struct PassThroughConstraintTransformer: ConstraintTransformer {
  let constraint: Constraint
  func calculate(_ constraint: Constraint) -> Constraint {
    self.constraint
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
      } else {
        assertionFailure("Can't fill an infinite x axis")
      }
    case .fit:
      break
    case .absolute(let value):
      maxSize.width = value
      minSize.width = value
    case .percentage(let value):
      let maxWidth = maxSize.width
      if maxWidth != .infinity {
        maxSize.width = value * maxWidth
        minSize.width = value * maxWidth
      } else {
        assertionFailure("Can't use percentage width an infinite x axis")
      }
    case .aspectPercentage(let value):
      let maxHeight = maxSize.height
      if maxHeight != .infinity {
        maxSize.width = value * maxHeight
        minSize.width = value * maxHeight
      } else {
        assertionFailure("Can't use aspectPercentage width an infinite y axis")
      }
    }
    switch height {
    case .fill:
      if maxSize.height != .infinity {
        minSize.height = maxSize.height
      } else {
        assertionFailure("Can't fill an infinite y axis")
      }
    case .fit:
      break
    case .absolute(let value):
      assert(value >= 0, "absolute value should be 0...")
      maxSize.height = value
      minSize.height = value
    case .percentage(let value):
      let maxHeight = maxSize.height
      if maxHeight != .infinity {
        maxSize.height = value * maxHeight
        minSize.height = value * maxHeight
      } else {
        assertionFailure("Can't use percentage height an infinite y axis")
      }
    case .aspectPercentage(let value):
      let maxWidth = maxSize.width
      if maxWidth != .infinity {
        maxSize.height = value * maxWidth
        minSize.height = value * maxWidth
      } else {
        assertionFailure("Can't use aspectPercentage height an infinite x axis")
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
    let finalConstraint = transformer.calculate(constraint)
    let renderer = child.layout(finalConstraint)
    return SizeOverrideRenderer(child: renderer, size: renderer.size.bound(to: finalConstraint))
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
  func size(_ size: CGSize) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
  }
  func size(width: SizeStrategy = .fit, height: CGFloat) -> Component {
    ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
  }
  func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> Component {
    ConstraintOverrideComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
  }
  func constraint(_ constraint: Constraint) -> Component {
    ConstraintOverrideComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
  }
  func unboundedWidth() -> Component {
    constraint { c in
      Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
    }
  }
  func unboundedHeight() -> Component {
    constraint { c in
      Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
    }
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
  func size(_ size: CGSize) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
  }
  func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
  }
  func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
  }
  func constraint(_ constraint: Constraint) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
  }
  func unboundedWidth() -> ConstraintOverrideViewComponent<R, Self> {
    constraint { c in
      Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
    }
  }
  func unboundedHeight() -> ConstraintOverrideViewComponent<R, Self> {
    constraint { c in
      Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
    }
  }
}
