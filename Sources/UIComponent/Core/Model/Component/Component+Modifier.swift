//  Created by Luke Zhao on 8/5/21.

import UIKit

/// A component produced by the ``Component/update(_:)`` modifier
public typealias UpdateComponent<Content: Component> = ModifierComponent<Content, UpdateRenderNode<Content.R>>

/// A component produced by the ``Component/with(_:_:)`` modifier
public typealias KeyPathUpdateComponent<Content: Component, Value> = ModifierComponent<Content, KeyPathUpdateRenderNode<Value, Content.R>>

/// A component produced by the ``Component/id(_:)`` modifier
public typealias IDComponent<Content: Component> = ModifierComponent<Content, IDRenderNode<Content.R>>

/// A component produced by the ``Component/animator(_:)`` modifier
public typealias AnimatorComponent<Content: Component> = ModifierComponent<Content, AnimatorRenderNode<Content.R>>

/// A component produced by ``Component/animateInsert(_:)``, ``Component/animateUpdate(passthrough:_:)``, & ``Component/animateUpdate(passthrough:_:)``  modifiers
public typealias AnimatorWrapperComponent<Content: Component> = ModifierComponent<Content, AnimatorWrapperRenderNode<Content.R>>

/// A component produced by the ``Component/reuseStrategy(_:)`` modifier
public typealias ReuseStrategyComponent<Content: Component> = ModifierComponent<Content, ReuseStrategyRenderNode<Content.R>>

extension Component {
    /// Provides a closure that acts as a modifier that can be used to modify a view property. This is used to support @dynamicMemberLookup, it should not be used directly.
    /// Example:
    /// ```swift
    /// ViewComponent<MyView>().myCustomProperty(value)
    /// ```
    /// - Parameter keyPath: A key path to a specific writable property on the underlying view.
    /// - Returns: A closure that takes a new value for the property and returns a `KeyPathUpdateComponent` representing the component with the updated value.
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> KeyPathUpdateComponent<Self, Value> {
        { value in
            with(keyPath, value)
        }
    }

    // MARK: - Parameter Override Modifiers

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
    ///
    /// There is also the ``Component/animateInsert(_:)``, ``Component/animateUpdate(passthrough:_:)``, and ``Component/animateDelete(_:)``
    /// modifiers that can be used to override insertions, updates, and deletions animation separately.
    ///
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

    // MARK: - Constraint Override Modifiers

    /// Adjusts the size of the component using specified strategies for width and height.
    /// - Parameters:
    ///   - width: A `SizeStrategy` value that determines the width sizing strategy. Defaults to `.fit`.
    ///   - height: A `SizeStrategy` value that determines the height sizing strategy. Defaults to `.fit`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }

    /// Sets an absolute width and uses a specified strategy for the height of the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that specifies the absolute width for the component.
    ///   - height: A `SizeStrategy` value that determines the height sizing strategy. Defaults to `.fit`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: CGFloat, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
    }

    /// Uses a specified strategy for the width and sets an absolute height for the component.
    /// - Parameters:
    ///   - width: A `SizeStrategy` value that determines the width sizing strategy. Defaults to `.fit`.
    ///   - height: A `CGFloat` value that specifies the absolute height for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
    }

    /// Sets an absolute size for the component.
    /// - Parameter size: A `CGSize` value that specifies the absolute size for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(_ size: CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }

    /// Sets an absolute size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that specifies the absolute width for the component.
    ///   - height: A `CGFloat` value that specifies the absolute height for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: CGFloat, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
    }

    /// Applies a custom constraint transformation to the component.
    /// - Parameter constraintComponent: A closure that takes a `Constraint` and returns a modified `Constraint`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with custom constraints.
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }

    /// Overrides the component's constraints with the specified constraints.
    /// - Parameter constraint: A `Constraint` object that specifies the constraints to be applied to the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden constraints.
    public func constraint(_ constraint: Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
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

    /// Sets the maximum size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that sets the maximum width. Defaults to `.infinity`.
    ///   - height: A `CGFloat` value that sets the maximum height. Defaults to `.infinity`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with maximum size constraints.
    public func maxSize(width: CGFloat = .infinity, height: CGFloat = .infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: min(width, c.maxSize.width), height: min(height, c.maxSize.height)))
        }
    }

    /// Sets the minimum size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that sets the minimum width. Defaults to `-.infinity`.
    ///   - height: A `CGFloat` value that sets the minimum height. Defaults to `-.infinity`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with minimum size constraints.
    public func minSize(width: CGFloat = -.infinity, height: CGFloat = -.infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: CGSize(width: max(width, c.minSize.width), height: max(height, c.minSize.height)), maxSize: c.maxSize)
        }
    }

    /// Applies the `.fit` size strategy to both width and height of the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the component with `.fit` size strategy applied.
    public func fit() -> ConstraintOverrideComponent<Self> {
        size(width: .fit, height: .fit)
    }

    /// Applies the `.fill` size strategy to both width and height of the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the component with `.fill` size strategy applied.
    public func fill() -> ConstraintOverrideComponent<Self> {
        size(width: .fill, height: .fill)
    }

    /// Centers the component within the parent's boundary
    /// - Returns: A `ZStack` component containing the centered component with `.fill` size strategy applied.
    public func centered() -> some Component {
        ZStack {
            self
        }.fill()
    }

    // MARK: - Conditional modifiers

    /// Conditionally applies a modification to the component if the given boolean value is true.
    /// - Parameters:
    ///   - value: A `Bool` that determines whether the modification should be applied.
    ///   - apply: A closure that takes the current component and returns a modified component.
    /// - Returns: The modified component if `value` is true, otherwise the original component.
    public func `if`(_ value: Bool, apply: (Self) -> any Component) -> AnyComponent {
        value ? apply(self).eraseToAnyComponent() : self.eraseToAnyComponent()
    }

    // MARK: - View wrapper modifiers

    /// Wraps the component in a `ComponentViewComponent` with a generic `ComponentView`.
    /// - Returns: A `ComponentViewComponent` that renders the component within a `ComponentView`.
    public func view() -> ComponentViewComponent<ComponentView> {
        ComponentViewComponent(component: self)
    }

    /// Wraps the component in a `ComponentViewComponent` with a `ComponentScrollView`.
    /// - Returns: A `ComponentViewComponent` that renders the component within a `ComponentScrollView`.
    public func scrollView() -> ComponentViewComponent<ComponentScrollView> {
        ComponentViewComponent(component: self)
    }

    // MARK: - Background modifiers

    /// Wraps the component with a background component.
    /// - Parameter component: The component to be used as the background.
    /// - Returns: A `Background` component that layers the background behind the current component.
    public func background(_ component: any Component) -> Background {
        Background(content: self, background: component)
    }

    /// Wraps the component with a background component, using a closure that returns the background component.
    /// - Parameter component: A closure that returns the component to be used as the background.
    /// - Returns: A `Background` component that layers the background behind the current component.
    public func background(_ component: () -> any Component) -> Background {
        Background(content: self, background: component())
    }

    // MARK: - Overlay modifiers

    /// Wraps the component with an overlay component.
    /// - Parameter component: The component to be used as the overlay.
    /// - Returns: An `Overlay` component that layers the overlay on top of the current component.
    public func overlay(_ component: any Component) -> Overlay {
        Overlay(content: self, overlay: component)
    }

    /// Wraps the component with an overlay component, using a closure that returns the overlay component.
    /// - Parameter component: A closure that returns the component to be used as the overlay.
    /// - Returns: An `Overlay` component that layers the overlay on top of the current component.
    public func overlay(_ component: () -> any Component) -> Overlay {
        Overlay(content: self, overlay: component())
    }

    // MARK: - Badge modifiers

    /// Adds a badge to the component with specified alignments and offset.
    /// - Parameters:
    ///   - component: The component to be used as the badge.
    ///   - verticalAlignment: The vertical alignment of the badge. Defaults to `.start`.
    ///   - horizontalAlignment: The horizontal alignment of the badge. Defaults to `.end`.
    ///   - offset: The offset point for the badge. Defaults to `.zero`.
    /// - Returns: A `Badge` component that places the badge relative to the current component.
    public func badge(
        _ component: any Component,
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero
    ) -> Badge {
        Badge(
            content: self,
            overlay: component,
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }

    /// Adds a badge to the component with specified alignments and offset, using a closure that returns the badge component.
    /// - Parameters:
    ///   - verticalAlignment: The vertical alignment of the badge. Defaults to `.start`.
    ///   - horizontalAlignment: The horizontal alignment of the badge. Defaults to `.end`.
    ///   - offset: The offset point for the badge. Defaults to `.zero`.
    ///   - component: A closure that returns the component to be used as the badge.
    /// - Returns: A `Badge` component that places the badge relative to the current component.
    public func badge(
        verticalAlignment: Badge.Alignment = .start,
        horizontalAlignment: Badge.Alignment = .end,
        offset: CGPoint = .zero,
        _ component: () -> any Component
    ) -> Badge {
        Badge(
            content: self,
            overlay: component(),
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            offset: offset
        )
    }

    // MARK: - Flex modifiers

    /// Applies flexible layout properties to the component. 
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///   - flex: The flex factor to be applied. Defaults to 1.
    ///   - alignSelf: The alignment of this component within a flex container. Defaults to nil.
    /// - Returns: A `Flexible` component that wraps the current component with the specified layout properties.
    public func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible<Self> {
        Flexible(flexGrow: flex, flexShrink: flex, alignSelf: alignSelf, content: self)
    }

    /// Applies flexible layout properties to the component with specified grow and shrink factors.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///   - flexGrow: The flex grow factor.
    ///   - flexShrink: The flex shrink factor.
    ///   - alignSelf: The alignment of this component within a flex container. Defaults to nil.
    /// - Returns: A `Flexible` component that wraps the current component with the specified layout properties.
    public func flex(flexGrow: CGFloat, flexShrink: CGFloat, alignSelf: CrossAxisAlignment? = nil) -> Flexible<Self> {
        Flexible(flexGrow: flexGrow, flexShrink: flexShrink, alignSelf: alignSelf, content: self)
    }

    // MARK: - Inset modifiers

    /// Applies uniform padding to all edges of the component.
    /// - Parameter amount: The padding amount to be applied to all edges.
    /// - Returns: A component wrapped with the specified amount of padding.
    public func inset(_ amount: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }

    /// Applies horizontal and vertical padding to the component.
    /// - Parameters:
    ///   - h: The horizontal padding amount.
    ///   - v: The vertical padding amount.
    /// - Returns: A component wrapped with the specified horizontal and vertical padding.
    public func inset(h: CGFloat, v: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies vertical and horizontal padding to the component.
    /// - Parameters:
    ///   - v: The vertical padding amount.
    ///   - h: The horizontal padding amount.
    /// - Returns: A component wrapped with the specified vertical and horizontal padding.
    public func inset(v: CGFloat, h: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies horizontal padding to the component.
    /// - Parameter h: The horizontal padding amount.
    /// - Returns: A component wrapped with the specified horizontal padding.
    public func inset(h: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }

    /// Applies vertical padding to the component.
    /// - Parameter v: The vertical padding amount.
    /// - Returns: A component wrapped with the specified vertical padding.
    public func inset(v: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }

    /// Applies padding to the component with specific values for each edge.
    /// - Parameters:
    ///   - top: The padding amount for the top edge.
    ///   - left: The padding amount for the left edge.
    ///   - bottom: The padding amount for the bottom edge.
    ///   - right: The padding amount for the right edge.
    /// - Returns: A component wrapped with the specified edge padding.
    public func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

    /// Applies padding to the component with a specific value for the top edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - top: The padding amount for the top edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(top: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: top, left: rest, bottom: rest, right: rest))
    }

    /// Applies padding to the component with a specific value for the left edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - left: The padding amount for the left edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(left: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: rest, left: left, bottom: rest, right: rest))
    }

    /// Applies padding to the component with a specific value for the bottom edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - bottom: The padding amount for the bottom edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(bottom: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: rest, left: rest, bottom: bottom, right: rest))
    }

    /// Applies padding to the component with a specific value for the right edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - right: The padding amount for the right edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(right: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: rest, left: rest, bottom: rest, right: right))
    }

    /// Applies padding to the component using the specified `UIEdgeInsets`.
    /// - Parameter insets: The `UIEdgeInsets` value to apply as padding.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(_ insets: UIEdgeInsets) -> some Component {
        Insets(content: self, insets: insets)
    }

    /// Applies dynamic padding to the component based on constraints at layout time.
    /// - Parameter insetProvider: A closure that provides `UIEdgeInsets` based on the given `Constraint`.
    /// - Returns: A component that dynamically adjusts its padding based on the provided insets.
    public func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> some Component {
        DynamicInsets(content: self, insetProvider: insetProvider)
    }

    // MARK: - Offset modifiers

    /// Applies an offset to the component using the specified `CGPoint`.
    /// - Parameter offset: The `CGPoint` value to apply as an offset.
    /// - Returns: A component offset by the specified point.
    public func offset(_ offset: CGPoint) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x))
    }

    /// Applies an offset to the component using separate x and y values.
    /// - Parameters:
    ///   - x: The horizontal offset.
    ///   - y: The vertical offset.
    /// - Returns: A component offset by the specified x and y values.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some Component {
        Insets(content: self, insets: UIEdgeInsets(top: y, left: x, bottom: -y, right: -x))
    }

    /// Applies a dynamic offset to the component based on constraints at layout time.
    /// - Parameter offsetProvider: A closure that provides a `CGPoint` based on the given `Constraint`.
    /// - Returns: A component that dynamically adjusts its offset based on the provided point.
    public func offset(_ offsetProvider: @escaping (Constraint) -> CGPoint) -> some Component {
        DynamicInsets(content: self) {
            let offset = offsetProvider($0)
            return UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x)
        }
    }

    // MARK: - Visible insets modifiers

    /// Applies uniform visible frame insets to the component.
    /// - Parameter amount: The padding amount for all edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(_ amount: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }

    /// Applies visible frame insets to the component with specified horizontal and vertical padding.
    /// - Parameters:
    ///   - h: The padding amount for the horizontal edges.
    ///   - v: The padding amount for the vertical edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(h: CGFloat, v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies visible frame insets to the component with specified vertical and horizontal padding.
    /// - Parameters:
    ///   - v: The padding amount for the vertical edges.
    ///   - h: The padding amount for the horizontal edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(v: CGFloat, h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies visible frame insets to the component with specified horizontal padding.
    /// - Parameter h: The padding amount for the horizontal edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: UIEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }

    /// Applies visible frame insets to the component with specified vertical padding.
    /// - Parameter v: The padding amount for the vertical edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: UIEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }

    /// Applies visible frame insets to the component using the specified `UIEdgeInsets`.
    /// - Parameter insets: The `UIEdgeInsets` value to apply as visible frame insets.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(_ insets: UIEdgeInsets) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: insets)
    }

    /// Applies dynamic visible frame insets to the component based on constraints at layout time.
    /// - Parameter insetProvider: A closure that provides `UIEdgeInsets` based on the given `CGRect`.
    /// - Returns: A component that dynamically adjusts its visible frame insets based on the provided insets.
    public func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> DynamicVisibleFrameInset<Self> {
        DynamicVisibleFrameInset(content: self, insetProvider: insetProvider)
    }

    /// Provides a reader for the render node of the component.
    /// - Parameter reader: A closure that receives the render node.
    /// - Returns: A `RenderNodeReader` component that allows reading the render node.
    public func renderNodeReader(_ reader: @escaping (Self.R) -> Void) -> RenderNodeReader<Self> {
        RenderNodeReader(content: self, reader)
    }

    /// Adds a callback to be invoked when the visible bounds of the component change.
    /// - Parameter callback: A closure that is called with the new size and visible rectangle.
    /// - Returns: A `VisibleBoundsObserverComponent` that invokes the callback when the visible bounds change.
    public func onVisibleBoundsChanged(_ callback: @escaping (CGSize, CGRect) -> Void) -> VisibleBoundsObserverComponent<Self> {
        VisibleBoundsObserverComponent(content: self, onVisibleBoundsChanged: callback)
    }

    // MARK: - View property modifiers

    /// Applies a rounded corner effect to the component by setting the `cornerRadius` of the view's layer.
    /// The radius is set to half of the minimum of the view's width and height, resulting in a circular shape if the view is square.
    public func roundedCorner() -> UpdateComponent<Self> {
        ModifierComponent(content: self) { node in
            node.update { view in
                view.layer.cornerRadius = min(node.size.width, node.size.height) / 2
            }
        }
    }

    // MARK: - TappableView modifiers

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - configuration: Optional `TappableViewConfig` to configure the tappable view.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    @available(*, deprecated, message: "Use .tappableView(_:).tappableViewConfig(_:) instead")
    public func tappableView(
        configuration: TappableViewConfig,
        _ onTap: @escaping (TappableView) -> Void
    ) -> EnvironmentComponent<TappableViewConfig, TappableViewComponent> {
        TappableViewComponent(
            component: self,
            onTap: onTap
        ).tappableViewConfig(configuration)
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - configuration: Optional `TappableViewConfig` to configure the tappable view.
    ///   - onTap: The closure to be called when the tappable view is tapped.
    @available(*, deprecated, message: "Use .tappableView(_:).tappableViewConfig(_:) instead")
    public func tappableView(
        configuration: TappableViewConfig,
        _ onTap: @escaping () -> Void
    ) -> EnvironmentComponent<TappableViewConfig, TappableViewComponent> {
        tappableView(configuration: configuration) { _ in
            onTap()
        }
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func tappableView(
        _ onTap: @escaping (TappableView) -> Void
    ) -> TappableViewComponent {
        TappableViewComponent(
            component: self,
            onTap: onTap
        )
    }

    /// Creates a tappable view component from the current component with a tap action. See ``TappableView`` for detail.
    /// - Parameters:
    ///   - onTap: The closure to be called when the tappable view is tapped.
    public func tappableView(
        _ onTap: @escaping () -> Void
    ) -> TappableViewComponent {
        tappableView { _ in
            onTap()
        }
    }
}

// MARK: - Primary Menu modifiers

@available(iOS 14.0, *)
public extension Component {
    /// Wrap the content in a component that displays the provided menu when tapped.
    /// - Parameter menu: A `UIMenu` to be displayed when the component is tapped.
    /// - Returns: A `PrimaryMenuComponent` containing the component and the menu.
    func primaryMenu(_ menu: UIMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menu: menu)
    }

    /// Wrap the content in a component that displays the provided menu when tapped.
    /// - Parameter menuBuilder: A closure that returns a `UIMenu` to be displayed when tapped.
    /// - Returns: A `PrimaryMenuComponent` containing the component and displays the menu when tapped.
    func primaryMenu(_ menuBuilder: @escaping () -> UIMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menuBuilder: menuBuilder)
    }
}

// MARK: - Environment modifiers
public extension Component {
    /// Applies an environment value to the component for the given key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific environment value.
    ///   - value: The value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyPath: keyPath, value: value, content: self)
    }

    /// Applies an environment value to the component for the given environment key type.
    /// - Parameters:
    ///   - keyType: The type of the environment key.
    ///   - value: The value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyType: any EnvironmentKey<Value>.Type, value: Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyType: keyType, value: value, content: self)
    }

    /// Applies an environment value to the component for the given key path.
    /// - Parameters:
    ///   - keyPath: A key path to a specific environment value.
    ///   - valueBuilder: A closure to be called to generate the value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, valueBuilder: () -> Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyPath: keyPath, value: valueBuilder(), content: self)
    }

    /// Applies an environment value to the component for the given environment key type.
    /// - Parameters:
    ///   - keyType: The type of the environment key.
    ///   - valueBuilder: A closure to be called to generate the value to set for the environment key.
    /// - Returns: An `EnvironmentComponent` that provides the environment value to the component.
    func environment<Value>(_ keyType: any EnvironmentKey<Value>.Type, valueBuilder: () -> Value) -> EnvironmentComponent<Value, Self> {
        EnvironmentComponent(keyType: keyType, value: valueBuilder(), content: self)
    }
}

// MARK: - Type erase modifiers

extension Component {
    /// Wraps the current component in a type-erased ``AnyComponent`` container.
    /// - Returns: A type erased ``AnyComponent`` that renders the same view as the current component.
    public func eraseToAnyComponent() -> AnyComponent {
        AnyComponent(content: self)
    }

    /// Wraps the current component in a type-erased ``AnyComponentOfView`` container.
    /// - Returns: A type erased``AnyComponentOfView`` that renders the same view as the current component.
    public func eraseToAnyComponentOfView() -> AnyComponentOfView<R.View> {
        AnyComponentOfView(content: self)
    }
}

// MARK: - Animation modifiers

extension Component {
    /// Animates layout update to the component (frame change).
    /// - Parameters:
    ///   - passthrough: A Boolean value that determines whether the animator update method will be called for the content component.
    ///   - updateBlock: A closure that is called to perform the layout update animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateUpdate(passthrough: passthrough, updateBlock)
        }
    }

    /// Animates the insertion of the component.
    /// - Parameter insertBlock: A closure that is called to perform the insertion animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateInsert(_ insertBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateInsert(insertBlock)
        }
    }

    /// Animates the deletion of the component.
    /// - Parameter deleteBlock: A closure that is called to perform the deletion animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateDelete(_ deleteBlock: @escaping (ComponentDisplayableView, UIView, @escaping () -> Void) -> Void) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateDelete(deleteBlock)
        }
    }
}
