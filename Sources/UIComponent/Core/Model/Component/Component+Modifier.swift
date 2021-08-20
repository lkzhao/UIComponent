//  Created by Luke Zhao on 8/5/21.

import UIKit

public extension Component {
  func `if`(_ value: Bool, apply: (Self) -> Component) -> Component {
    value ? apply(self) : self
  }
}

public extension Component {
  func view() -> ComponentViewComponent<ComponentView> {
    ComponentViewComponent(component: self)
  }

  func scrollView() -> ComponentViewComponent<ComponentScrollView> {
    ComponentViewComponent(component: self)
  }
}

public extension Component {
  func background(_ component: Component) -> Background {
    Background(child: self, background: component)
  }
  func background(_ component: () -> Component) -> Background {
    Background(child: self, background: component())
  }
}

public extension Component {
  func overlay(_ component: Component) -> Overlay {
    Overlay(child: self, overlay: component)
  }
  func overlay(_ component: () -> Component) -> Overlay {
    Overlay(child: self, overlay: component())
  }
}

public extension Component {
  func badge(_ component: Component,
             verticalAlignment: CrossAxisAlignment = .start,
             horizontalAlignment: CrossAxisAlignment = .end,
             offset: CGVector = .zero) -> Badge {
    Badge(child: self,
          overlay: component,
          verticalAlignment: verticalAlignment,
          horizontalAlignment: horizontalAlignment,
          offset: offset)
  }
  func badge(verticalAlignment: CrossAxisAlignment = .start,
             horizontalAlignment: CrossAxisAlignment = .end,
             offset: CGVector = .zero,
             _ component: () -> Component) -> Badge {
    Badge(child: self,
          overlay: component(),
          verticalAlignment: verticalAlignment,
          horizontalAlignment: horizontalAlignment,
          offset: offset)
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible {
    Flexible(flex: flex, alignSelf: alignSelf, child: self)
  }
}

public extension Component {
  func inset(_ amount: CGFloat) -> Component {
    Insets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  func inset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
    Insets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Component {
    Insets(insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), child: self)
  }
  func inset(by insets: UIEdgeInsets) -> Component {
    Insets(insets: insets, child: self)
  }
  func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> Component {
    DynamicInsets(insetProvider: insetProvider, child: self)
  }
}

public extension Component {
  func visibleInset(_ amount: CGFloat) -> Component {
    VisibleFrameInsets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  func visibleInset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
    VisibleFrameInsets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  func visibleInset(_ insets: UIEdgeInsets) -> Component {
    VisibleFrameInsets(insets: insets, child: self)
  }
  func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> Component {
    DynamicVisibleFrameInset(insetProvider: insetProvider, child: self)
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

public extension Component {
  func renderNodeReader(_ reader: @escaping (RenderNode) -> Void) -> RenderNodeReader {
    RenderNodeReader(child: self, reader)
  }
}
