//  Created by Luke Zhao on 8/5/21.

import UIKit

extension Component {
    public func `if`(_ value: Bool, apply: (Self) -> Component) -> Component {
        value ? apply(self) : self
    }
}

extension Component {
    public func view() -> ComponentViewComponent<ComponentView> {
        ComponentViewComponent(component: self)
    }

    public func scrollView() -> ComponentViewComponent<ComponentScrollView> {
        ComponentViewComponent(component: self)
    }
}

extension Component {
    public func background(_ component: Component) -> Background {
        Background(child: self, background: component)
    }
    public func background(_ component: () -> Component) -> Background {
        Background(child: self, background: component())
    }
}

extension Component {
    public func overlay(_ component: Component) -> Overlay {
        Overlay(child: self, overlay: component)
    }
    public func overlay(_ component: () -> Component) -> Overlay {
        Overlay(child: self, overlay: component())
    }
}

extension Component {
    public func badge(
        _ component: Component,
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero
    ) -> Badge {
        Badge(
            child: self,
            overlay: component,
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }
    public func badge(
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero,
        _ component: () -> Component
    ) -> Badge {
        Badge(
            child: self,
            overlay: component(),
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }
}

extension Component {
    public func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible {
        Flexible(flexGrow: flex, flexShrink: flex, alignSelf: alignSelf, child: self)
    }
    public func flex(flexGrow: CGFloat, flexShrink: CGFloat, alignSelf: CrossAxisAlignment? = nil) -> Flexible {
        Flexible(flexGrow: flexGrow, flexShrink: flexShrink, alignSelf: alignSelf, child: self)
    }
}

extension Component {
    public func inset(_ amount: CGFloat) -> Component {
        Insets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
    }
    public func inset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
        Insets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
    }
    public func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Component {
        Insets(insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), child: self)
    }
    public func inset(by insets: UIEdgeInsets) -> Component {
        Insets(insets: insets, child: self)
    }
    public func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> Component {
        DynamicInsets(insetProvider: insetProvider, child: self)
    }
}

extension Component {
    public func visibleInset(_ amount: CGFloat) -> Component {
        VisibleFrameInsets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
    }
    public func visibleInset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
        VisibleFrameInsets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
    }
    public func visibleInset(_ insets: UIEdgeInsets) -> Component {
        VisibleFrameInsets(insets: insets, child: self)
    }
    public func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> Component {
        DynamicVisibleFrameInset(insetProvider: insetProvider, child: self)
    }
}

extension Component {
    public func maxSize(width: CGFloat = .infinity, height: CGFloat = .infinity) -> Component {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: min(width, c.maxSize.width), height: min(height, c.maxSize.height)))
        }
    }
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> Component {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }
    public func size(width: CGFloat, height: SizeStrategy = .fit) -> Component {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
    }
    public func size(width: CGFloat, height: CGFloat) -> Component {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
    }
    public func size(_ size: CGSize) -> Component {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }
    public func size(width: SizeStrategy = .fit, height: CGFloat) -> Component {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
    }
    public func fit() -> Component {
        size(width: .fit, height: .fit)
    }
    public func fill() -> Component {
        size(width: .fill, height: .fill)
    }
    public func centered() -> Component {
        ZStack {
            self
        }
        .fill()
    }
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> Component {
        ConstraintOverrideComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }
    public func constraint(_ constraint: Constraint) -> Component {
        ConstraintOverrideComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
    }
    public func unboundedWidth() -> Component {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }
    public func unboundedHeight() -> Component {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }
}

extension Component {
    public func renderNodeReader(_ reader: @escaping (RenderNode) -> Void) -> RenderNodeReader {
        RenderNodeReader(child: self, reader)
    }
}
