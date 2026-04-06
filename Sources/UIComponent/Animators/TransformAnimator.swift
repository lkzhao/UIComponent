//  Created by Luke Zhao on 2018-12-27.

@available(*, deprecated, renamed: "TransformAnimator")
public typealias AnimatedReloadAnimator = TransformAnimator

/// A simple Animator implementation that applies a transform and fade
/// animation during deletion and insertion.
public struct TransformAnimator: Animator {
    /// The timing configuration used for insert, delete, and update animations.
    public enum Timing: Equatable {
        case linear
        case easeIn
        case easeInOut
        case easeOut
        case springBounce(bounce: CGFloat, initialSpringVelocity: CGFloat = 0)
        case springDamping(damping: CGFloat, initialSpringVelocity: CGFloat = 0)

        public static func spring(
            bounce: CGFloat,
            initialSpringVelocity: CGFloat = 0
        ) -> Self {
            .springBounce(bounce: bounce, initialSpringVelocity: initialSpringVelocity)
        }

        public static func spring(
            damping: CGFloat,
            initialSpringVelocity: CGFloat = 0
        ) -> Self {
            .springDamping(damping: damping, initialSpringVelocity: initialSpringVelocity)
        }

        internal func animate(
            duration: TimeInterval,
            layoutSubviews: Bool,
            delay: TimeInterval = 0,
            animations: @escaping () -> Void,
            completion: ((Bool) -> Void)? = nil
        ) {
            var options: UIView.AnimationOptions = [.allowUserInteraction]
            if layoutSubviews {
                options.insert(.layoutSubviews)
            }
            switch self {
            case .linear:
                options.insert(.curveLinear)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case .easeIn:
                options.insert(.curveEaseIn)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case .easeInOut:
                options.insert(.curveEaseInOut)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case .easeOut:
                options.insert(.curveEaseOut)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case let .springBounce(bounce: bounce, initialSpringVelocity: initialSpringVelocity):
                if #available(iOS 17.0, tvOS 17.0, *) {
                    UIView.animate(
                        springDuration: duration,
                        bounce: bounce.clamped(to: 0...1),
                        initialSpringVelocity: initialSpringVelocity,
                        delay: delay,
                        options: options,
                        animations: animations,
                        completion: completion
                    )
                } else {
                    // Approximate newer bounce-based springs on older platforms.
                    UIView.animate(
                        withDuration: duration,
                        delay: delay,
                        usingSpringWithDamping: (1 - bounce).clamped(to: 0...1),
                        initialSpringVelocity: initialSpringVelocity,
                        options: options,
                        animations: animations,
                        completion: completion
                    )
                }
            case let .springDamping(damping: damping, initialSpringVelocity: initialSpringVelocity):
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    usingSpringWithDamping: damping.clamped(to: 0...1),
                    initialSpringVelocity: initialSpringVelocity,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            }
        }
    }

    /// The 3D transform applied to the view at the start of insertion animations.
    public var insertTransform: CATransform3D
    /// The 3D transform applied to the view at the end of deletion animations.
    public var deleteTransform: CATransform3D
    /// Compatibility alias for configuring the same transform for both insertion and deletion.
    public var transform: CATransform3D {
        get { insertTransform }
        set {
            insertTransform = newValue
            deleteTransform = newValue
        }
    }
    /// The timing configuration used for all animations.
    public var timing: Timing
    /// The duration of the animation in seconds.
    public var duration: TimeInterval
    /// A Boolean value that determines whether the animation should be applied in a cascading manner.
    public var cascade: Bool
    /// A Boolean value that determines whether animation blocks should include the `.layoutSubviews` option.
    public var layoutSubviews: Bool
    /// A Boolean value that determines whether to show the initial insertion animation when the view is first loaded.
    public var showInitialInsertionAnimation: Bool = false
    /// A Boolean value that determines whether to show insertion animations for items that are out of the bounds of the hosting view.
    public var showInsertionAnimationOnOutOfBoundsItems: Bool = false

    /// Initializes a new animator with the specified insertion and deletion transforms,
    /// timing, and cascade options.
    /// - Parameters:
    ///   - insertTransform: The 3D transform to apply to the view at the start of insertion animations.
    ///     Defaults to the identity transform.
    ///   - deleteTransform: The 3D transform to apply to the view at the end of deletion animations.
    ///     Defaults to the identity transform.
    ///   - timing: The timing configuration used for insert, delete, and update animations.
    ///     Defaults to a spring with `0.9` damping.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        insertTransform: CATransform3D = CATransform3DIdentity,
        deleteTransform: CATransform3D = CATransform3DIdentity,
        timing: Timing = .spring(damping: 0.9, initialSpringVelocity: 0),
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.insertTransform = insertTransform
        self.deleteTransform = deleteTransform
        self.timing = timing
        self.duration = duration
        self.cascade = cascade
        self.layoutSubviews = layoutSubviews
        self.showInitialInsertionAnimation = showInitialInsertionAnimation
        self.showInsertionAnimationOnOutOfBoundsItems = showInsertionAnimationOnOutOfBoundsItems
    }

    /// Initializes a new animator with the specified insertion and deletion transforms,
    /// duration, and cascade options.
    /// - Parameters:
    ///   - insertTransform: The 3D transform to apply to the view at the start of insertion animations.
    ///     Defaults to the identity transform.
    ///   - deleteTransform: The 3D transform to apply to the view at the end of deletion animations.
    ///     Defaults to the identity transform.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        insertTransform: CATransform3D = CATransform3DIdentity,
        deleteTransform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: insertTransform,
            deleteTransform: deleteTransform,
            timing: .spring(damping: 0.9, initialSpringVelocity: 0),
            duration: duration,
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    /// Initializes a new animator that uses the same transform for insertion and deletion.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to both insertion and deletion animations.
    ///     Defaults to the identity transform.
    ///   - timing: The timing configuration used for insert, delete, and update animations.
    ///     Defaults to a spring with `0.9` damping.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        transform: CATransform3D = CATransform3DIdentity,
        timing: Timing = .spring(damping: 0.9, initialSpringVelocity: 0),
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: transform,
            deleteTransform: transform,
            timing: timing,
            duration: duration,
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    /// Initializes a new animator that uses the same transform for insertion and deletion.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to both insertion and deletion animations.
    ///     Defaults to the identity transform.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        transform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: transform,
            deleteTransform: transform,
            timing: .spring(damping: 0.9, initialSpringVelocity: 0),
            duration: duration,
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    public func delete(hostingView: UIView, view: UIView, completion: @escaping () -> Void) {
        if hostingView.componentEngine.isReloading, hostingView.bounds.intersects(view.frame) {
            let baseTransform = view.layer.transform
            timing.animate(
                duration: duration,
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.layer.transform = deleteTransform
                    view.alpha = 0
                },
                completion: { _ in
                    if !hostingView.componentEngine.visibleViews.contains(view) {
                        view.layer.transform = baseTransform
                        view.alpha = 1
                    }
                    completion()
                }
            )
        } else {
            completion()
        }
    }

    public func insert(hostingView: UIView, view: UIView, frame: CGRect) {
        view.bounds.size = frame.size
        view.center = frame.center
        let baseTransform = view.layer.transform
        if hostingView.componentEngine.isReloading, showInitialInsertionAnimation || hostingView.componentEngine.hasReloaded, showInsertionAnimationOnOutOfBoundsItems || hostingView.bounds.intersects(frame) {
            let offsetTime: TimeInterval = cascade ? TimeInterval(frame.origin.distance(hostingView.bounds.origin) / 3000) : 0
            UIView.performWithoutAnimation {
                view.layer.transform = insertTransform
                view.alpha = 0
            }
            timing.animate(
                duration: duration,
                layoutSubviews: layoutSubviews,
                delay: offsetTime,
                animations: {
                    view.layer.transform = baseTransform
                    view.alpha = 1
                }
            )
        }
    }

    public func update(hostingView _: UIView, view: UIView, frame: CGRect) {
        if view.center != frame.center {
            timing.animate(
                duration: duration,
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.center = frame.center
                },
                completion: nil
            )
        }
        if view.bounds.size != frame.bounds.size {
            timing.animate(
                duration: duration,
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.bounds.size = frame.bounds.size
                },
                completion: nil
            )
        }
        if view.alpha != 1 {
            timing.animate(
                duration: duration,
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.alpha = 1
                },
                completion: nil
            )
        }
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
