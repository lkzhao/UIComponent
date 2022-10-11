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
        Insets(child: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }
    public func inset(h: CGFloat, v: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func inset(v: CGFloat, h: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func inset(h: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }
    public func inset(v: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }
    public func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    public func inset(top: CGFloat, rest: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: top, rest: rest))
    }
    public func inset(left: CGFloat, rest: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(left: left, rest: rest))
    }
    public func inset(bottom: CGFloat, rest: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(bottom: bottom, rest: rest))
    }
    public func inset(right: CGFloat, rest: CGFloat) -> Component {
        Insets(child: self, insets: UIEdgeInsets(right: right, rest: rest))
    }
    public func inset(_ insets: UIEdgeInsets) -> Component {
        Insets(child: self, insets: insets)
    }
    public func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> Component {
        DynamicInsets(child: self, insetProvider: insetProvider)
    }
}

extension Component {
    public func offset(_ offset: CGPoint) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x))
    }
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> Component {
        Insets(child: self, insets: UIEdgeInsets(top: y, left: x, bottom: -y, right: -x))
    }
    public func offset(_ offsetProvider: @escaping (Constraint) -> CGPoint) -> Component {
        DynamicInsets(child: self) {
            let offset = offsetProvider($0)
            return UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x)
        }
    }
}

extension Component {
    public func visibleInset(_ amount: CGFloat) -> Component {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }
    public func visibleInset(h: CGFloat, v: CGFloat) -> Component {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func visibleInset(v: CGFloat, h: CGFloat) -> Component {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func visibleInset(h: CGFloat) -> Component {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }
    public func visibleInset(v: CGFloat) -> Component {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }
    public func visibleInset(_ insets: UIEdgeInsets) -> Component {
        VisibleFrameInsets(child: self, insets: insets)
    }
    public func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> Component {
        DynamicVisibleFrameInset(child: self, insetProvider: insetProvider)
    }
}

extension Component {
    public func maxSize(width: CGFloat = .infinity, height: CGFloat = .infinity) -> Component {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: min(width, c.maxSize.width), height: min(height, c.maxSize.height)))
        }
    }
    public func minSize(width: CGFloat = -.infinity, height: CGFloat = -.infinity) -> Component {
        constraint { c in
            Constraint(minSize: CGSize(width: max(width, c.minSize.width), height: max(height, c.minSize.height)), maxSize: c.maxSize)
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
    /// Read the RenderNode
    /// - Parameter reader: the RenderNode that gets generated on component layout
    /// - Returns: RenderNodeReader
    public func renderNodeReader(_ reader: @escaping (RenderNode) -> Void) -> RenderNodeReader {
        RenderNodeReader(child: self, reader)
    }
}

extension Component {
    /// Observe the visible bounds change of the current component
    /// - Parameter callback: Called when the visible bounds changed with the current component's size and its visible bounds.
    /// - Returns: Component
    public func onVisibleBoundsChanged(_ callback: @escaping (CGSize, CGRect) -> Void) -> VisibleBoundsObserverComponent {
        VisibleBoundsObserverComponent(child: self, onVisibleBoundsChanged: callback)
    }
}
