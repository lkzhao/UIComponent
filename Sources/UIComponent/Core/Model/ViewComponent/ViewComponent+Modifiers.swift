//  Created by Luke Zhao on 8/19/21.

import Foundation

public extension ViewComponent {
  subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> ViewKeyPathUpdateComponent<Self, Value> {
    { with(keyPath, $0) }
  }

  func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewKeyPathUpdateComponent<Self, Value> {
    ViewModifierComponent(content: self) {
      $0.with(keyPath, value)
    }
  }

  func id(_ id: String) -> ViewIDComponent<Self> {
    ViewModifierComponent(content: self) {
      $0.id(id)
    }
  }

  func animator(_ animator: Animator?) -> ViewAnimatorComponent<Self> {
    ViewModifierComponent(content: self) {
      $0.animator(animator)
    }
  }

  func reuseKey(_ reuseKey: String?) -> ViewReuseKeyComponent<Self> {
    ViewModifierComponent(content: self) {
      $0.reuseKey(reuseKey)
    }
  }

  func update(_ update: @escaping (R.View) -> Void) -> ViewUpdateComponent<Self> {
    ViewModifierComponent(content: self) {
      $0.update(update)
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
