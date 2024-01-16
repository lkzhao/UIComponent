//  Created by Luke Zhao on 8/5/21.

import UIKit

public typealias UpdateComponent<Content: Component> = ModifierComponent<Content, UpdateRenderNode<Content.R>>

public typealias KeyPathUpdateComponent<Content: Component, Value> = ModifierComponent<Content, KeyPathUpdateRenderNode<Value, Content.R>>

public typealias IDComponent<Content: Component> = ModifierComponent<Content, IDRenderNode<Content.R>>

public typealias AnimatorComponent<Content: Component> = ModifierComponent<Content, AnimatorRenderNode<Content.R>>

public typealias AnimatorWrapperComponent<Content: Component> = ModifierComponent<Content, AnimatorWrapperRenderNode<Content.R>>

public typealias ReuseStrategyComponent<Content: Component> = ModifierComponent<Content, ReuseStrategyRenderNode<Content.R>>

extension Component {
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> KeyPathUpdateComponent<Self, Value> {
        { value in
            with(keyPath, value)
        }
    }

    /// Applies a value to a property of the underlying view specified by a key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific property on the underlying view.
    ///   - value: The value to set for the property specified by keyPath.
    /// - Returns: A `KeyPathUpdateComponent` that represents the modified component.
    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> KeyPathUpdateComponent<Self, Value> {
        ModifierComponent(content: self) {
            $0.with(keyPath, value)
        }
    }

    /// Assigns an identifier to the component.
    /// - Parameter id: An optional string that uniquely identifies the component.
    /// - Returns: An `IDComponent` that represents the modified component with an assigned ID.
    public func id(_ id: String?) -> IDComponent<Self> {
        ModifierComponent(content: self) {
            $0.id(id)
        }
    }

    /// Associates an animator with the component.
    /// - Parameter animator: An optional `Animator` object that defines how the component's updates are animated.
    /// - Returns: An `AnimatorComponent` that represents the modified component with an associated animator.
    public func animator(_ animator: Animator?) -> AnimatorComponent<Self> {
        ModifierComponent(content: self) {
            $0.animator(animator)
        }
    }

    /// Sets the reuse strategy for the component.
    /// - Parameter reuseStrategy: A `ReuseStrategy` value that determines how the component should handle reuse.
    /// - Returns: A `ReuseStrategyComponent` that represents the modified component with a specified reuse strategy.
    public func reuseStrategy(_ reuseStrategy: ReuseStrategy) -> ReuseStrategyComponent<Self> {
        ModifierComponent(content: self) {
            $0.reuseStrategy(reuseStrategy)
        }
    }

    /// Registers a closure to be called when the component is updated.
    /// - Parameter update: A closure that takes the component's underlying view as its parameter.
    /// - Returns: An `UpdateComponent` that represents the modified component with an update closure.
    public func update(_ update: @escaping (R.View) -> Void) -> UpdateComponent<Self> {
        ModifierComponent(content: self) {
            $0.update(update)
        }
    }

    // MARK: - Constraint Overrides Modifiers

    /// Adjusts the size of the component using specified strategies for width and height.
    /// - Parameters:
    ///   - width: A `SizeStrategy` value that determines the width sizing strategy. Defaults to `.fit`.
    ///   - height: A `SizeStrategy` value that determines the height sizing strategy. Defaults to `.fit`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }

    /// Sets an absolute size for the component.
    /// - Parameter size: A `CGSize` value that specifies the absolute size for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(_ size: CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }

    /// Applies a custom constraint transformation to the component.
    /// - Parameter constraintComponent: A closure that takes a `Constraint` and returns a modified `Constraint`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with custom constraints.
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }

    /// Overrides the component's constraints with the specified constraints.
    /// - Parameter constraint: A `Constraint` object that specifies the constraints to be applied to the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden constraints.
    public func constraint(_ constraint: Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
    }

    /// Removes the upper bound on the component's width, allowing it to grow indefinitely.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with an unbounded width.
    public func unboundedWidth() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }

    /// Removes the upper bound on the component's height, allowing it to grow indefinitely.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with an unbounded height.
    public func unboundedHeight() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }

    public func maxSize(width: CGFloat = .infinity, height: CGFloat = .infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: min(width, c.maxSize.width), height: min(height, c.maxSize.height)))
        }
    }

    public func minSize(width: CGFloat = -.infinity, height: CGFloat = -.infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: CGSize(width: max(width, c.minSize.width), height: max(height, c.minSize.height)), maxSize: c.maxSize)
        }
    }

    public func fit() -> ConstraintOverrideComponent<Self> {
        size(width: .fit, height: .fit)
    }

    public func fill() -> ConstraintOverrideComponent<Self> {
        size(width: .fill, height: .fill)
    }

    public func centered() -> some Component {
        ZStack {
            self
        }.fill()
    }

    public func roundedCorner() -> UpdateComponent<Self> {
        ModifierComponent(content: self) { node in
            node.update { view in
                view.layer.cornerRadius = min(node.size.width, node.size.height) / 2
            }
        }
    }

    
    public func `if`(_ value: Bool, apply: (Self) -> any Component) -> AnyComponent {
        value ? apply(self).eraseToAnyComponent() : self.eraseToAnyComponent()
    }

    
    public func view() -> ComponentViewComponent<ComponentView> {
        ComponentViewComponent(component: self)
    }

    public func scrollView() -> ComponentViewComponent<ComponentScrollView> {
        ComponentViewComponent(component: self)
    }

    
    public func background(_ component: any Component) -> Background {
        Background(child: self, background: component)
    }
    public func background(_ component: () -> any Component) -> Background {
        Background(child: self, background: component())
    }

    
    public func overlay(_ component: any Component) -> Overlay {
        Overlay(child: self, overlay: component)
    }
    public func overlay(_ component: () -> any Component) -> Overlay {
        Overlay(child: self, overlay: component())
    }

    
    public func badge(
        _ component: any Component,
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
        _ component: () -> any Component
    ) -> Badge {
        Badge(
            child: self,
            overlay: component(),
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }

    
    public func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible<Self> {
        Flexible(flexGrow: flex, flexShrink: flex, alignSelf: alignSelf, child: self)
    }
    public func flex(flexGrow: CGFloat, flexShrink: CGFloat, alignSelf: CrossAxisAlignment? = nil) -> Flexible<Self> {
        Flexible(flexGrow: flexGrow, flexShrink: flexShrink, alignSelf: alignSelf, child: self)
    }


    public func inset(_ amount: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }
    public func inset(h: CGFloat, v: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func inset(v: CGFloat, h: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func inset(h: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }
    public func inset(v: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }
    public func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    public func inset(top: CGFloat, rest: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: top, left: rest, bottom: rest, right: rest))
    }
    public func inset(left: CGFloat, rest: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: rest, left: left, bottom: rest, right: rest))
    }
    public func inset(bottom: CGFloat, rest: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: rest, left: rest, bottom: bottom, right: rest))
    }
    public func inset(right: CGFloat, rest: CGFloat) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: rest, left: rest, bottom: rest, right: right))
    }
    public func inset(_ insets: UIEdgeInsets) -> some Component {
        Insets(child: self, insets: insets)
    }
    public func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> some Component {
        DynamicInsets(child: self, insetProvider: insetProvider)
    }


    public func offset(_ offset: CGPoint) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x))
    }
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some Component {
        Insets(child: self, insets: UIEdgeInsets(top: y, left: x, bottom: -y, right: -x))
    }
    public func offset(_ offsetProvider: @escaping (Constraint) -> CGPoint) -> some Component {
        DynamicInsets(child: self) {
            let offset = offsetProvider($0)
            return UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x)
        }
    }



    public func visibleInset(_ amount: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }
    public func visibleInset(h: CGFloat, v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func visibleInset(v: CGFloat, h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }
    public func visibleInset(h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }
    public func visibleInset(v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }
    public func visibleInset(_ insets: UIEdgeInsets) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(child: self, insets: insets)
    }
    public func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> DynamicVisibleFrameInset<Self> {
        DynamicVisibleFrameInset(child: self, insetProvider: insetProvider)
    }



    public func renderNodeReader(_ reader: @escaping (any RenderNode) -> Void) -> RenderNodeReader<Self> {
        RenderNodeReader(child: self, reader)
    }

    public func onVisibleBoundsChanged(_ callback: @escaping (CGSize, CGRect) -> Void) -> VisibleBoundsObserverComponent<Self> {
        VisibleBoundsObserverComponent(child: self, onVisibleBoundsChanged: callback)
    }
}

// MARK: Experimental

extension Component {
    public func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateUpdate(passthrough: passthrough, updateBlock)
        }
    }
}
