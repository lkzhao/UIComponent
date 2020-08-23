//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

struct SizeOverrideRenderer: Renderer {
  let child: Renderer
  let size: CGSize
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame)
  }
}

struct ConstraintOverrideComponent: Component {
  let child: Component
  let constraintBlock: (Constraint) -> Constraint
  func layout(_ constraint: Constraint) -> Renderer {
    child.layout(constraintBlock(constraint))
  }
}

public struct ConstraintOverrideViewComponent<R, Content: ViewComponent>: ViewComponent where R == Content.R {
  let child: Content
  let constraintBlock: (Constraint) -> Constraint
  public func layout(_ constraint: Constraint) -> R {
    child.layout(constraintBlock(constraint))
  }
}

public extension Component {
  func size(width: CGFloat? = nil, height: CGFloat? = nil) -> Component {
    ConstraintOverrideComponent(child: self) { c in
      Constraint(maxSize: CGSize(width: width ?? c.maxSize.width, height: height ?? c.maxSize.height),
                 minSize: CGSize(width: width ?? c.minSize.width, height: height ?? c.minSize.height))
    }
  }
}

public extension ViewComponent {
  func size(width: CGFloat? = nil, height: CGFloat? = nil) -> ConstraintOverrideViewComponent<R, Self> {
    ConstraintOverrideViewComponent(child: self) { c in
      Constraint(maxSize: CGSize(width: width ?? c.maxSize.width, height: height ?? c.maxSize.height),
                 minSize: CGSize(width: width ?? c.minSize.width, height: height ?? c.minSize.height))
    }
  }
}
