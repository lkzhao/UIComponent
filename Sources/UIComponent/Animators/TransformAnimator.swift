//  Created by Luke Zhao on 2018-12-27.

@available(*, deprecated, renamed: "TransformAnimator")
public typealias AnimatedReloadAnimator = TransformAnimator

/// A simple Animator implementation that applies a transform and fade
/// animation during deletion and insertion.
public struct TransformAnimator: Animator {
    /// The timing configuration used for insert, delete, and update animations.
    public enum Timing: Equatable {
        case linear(duration: TimeInterval = 0.5)
        case easeIn(duration: TimeInterval = 0.5)
        case easeInOut(duration: TimeInterval = 0.5)
        case easeOut(duration: TimeInterval = 0.5)
        case springBounce(duration: TimeInterval = 0.5, bounce: CGFloat, initialSpringVelocity: CGFloat = 0)
        case springDamping(duration: TimeInterval = 0.5, damping: CGFloat, initialSpringVelocity: CGFloat = 0)

        public static func spring(
            duration: TimeInterval = 0.5,
            bounce: CGFloat,
            initialSpringVelocity: CGFloat = 0
        ) -> Self {
            .springBounce(duration: duration, bounce: bounce, initialSpringVelocity: initialSpringVelocity)
        }

        public static func spring(
            duration: TimeInterval = 0.5,
            damping: CGFloat,
            initialSpringVelocity: CGFloat = 0
        ) -> Self {
            .springDamping(duration: duration, damping: damping, initialSpringVelocity: initialSpringVelocity)
        }

        public var duration: TimeInterval {
            switch self {
            case let .linear(duration),
                 let .easeIn(duration),
                 let .easeInOut(duration),
                 let .easeOut(duration),
                 let .springBounce(duration, bounce: _, initialSpringVelocity: _),
                 let .springDamping(duration, damping: _, initialSpringVelocity: _):
                return duration
            }
        }

        public func withDuration(_ duration: TimeInterval) -> Self {
            switch self {
            case .linear:
                .linear(duration: duration)
            case .easeIn:
                .easeIn(duration: duration)
            case .easeInOut:
                .easeInOut(duration: duration)
            case .easeOut:
                .easeOut(duration: duration)
            case let .springBounce(duration: _, bounce: bounce, initialSpringVelocity: initialSpringVelocity):
                .spring(duration: duration, bounce: bounce, initialSpringVelocity: initialSpringVelocity)
            case let .springDamping(duration: _, damping: damping, initialSpringVelocity: initialSpringVelocity):
                .spring(duration: duration, damping: damping, initialSpringVelocity: initialSpringVelocity)
            }
        }

        internal func animate(
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
            case let .linear(duration):
                options.insert(.curveLinear)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case let .easeIn(duration):
                options.insert(.curveEaseIn)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case let .easeInOut(duration):
                options.insert(.curveEaseInOut)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case let .easeOut(duration):
                options.insert(.curveEaseOut)
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: options,
                    animations: animations,
                    completion: completion
                )
            case let .springBounce(duration: duration, bounce: bounce, initialSpringVelocity: initialSpringVelocity):
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
            case let .springDamping(duration: duration, damping: damping, initialSpringVelocity: initialSpringVelocity):
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
    /// The timing configuration used for insertion animations.
    public var insertTiming: Timing
    /// The timing configuration used for update animations.
    public var updateTiming: Timing
    /// The timing configuration used for deletion animations.
    public var deleteTiming: Timing
    /// Compatibility alias for using the same timing configuration for insert, update, and delete.
    public var timing: Timing {
        get { insertTiming }
        set {
            insertTiming = newValue
            updateTiming = newValue
            deleteTiming = newValue
        }
    }
    /// Compatibility alias for updating all timing durations together.
    public var duration: TimeInterval {
        get { insertTiming.duration }
        set {
            insertTiming = insertTiming.withDuration(newValue)
            updateTiming = updateTiming.withDuration(newValue)
            deleteTiming = deleteTiming.withDuration(newValue)
        }
    }
    /// A Boolean value that determines whether the animation should be applied in a cascading manner.
    public var cascade: Bool
    /// A Boolean value that determines whether animation blocks should include the `.layoutSubviews` option.
    public var layoutSubviews: Bool
    /// A Boolean value that determines whether to show the initial insertion animation when the view is first loaded.
    public var showInitialInsertionAnimation: Bool = false
    /// A Boolean value that determines whether to show insertion animations for items that are out of the bounds of the hosting view.
    public var showInsertionAnimationOnOutOfBoundsItems: Bool = false

    /// Initializes a new animator with the specified insertion and deletion transforms,
    /// insert/update/delete timings, and cascade options.
    /// - Parameters:
    ///   - insertTransform: The 3D transform to apply to the view at the start of insertion animations.
    ///     Defaults to the identity transform.
    ///   - deleteTransform: The 3D transform to apply to the view at the end of deletion animations.
    ///     Defaults to the identity transform.
    ///   - insertTiming: The timing configuration used for insertion animations.
    ///   - updateTiming: The timing configuration used for update animations.
    ///   - deleteTiming: The timing configuration used for deletion animations.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        insertTransform: CATransform3D = CATransform3DIdentity,
        deleteTransform: CATransform3D = CATransform3DIdentity,
        insertTiming: Timing = .spring(duration: 0.5, damping: 0.9, initialSpringVelocity: 0),
        updateTiming: Timing = .spring(duration: 0.5, damping: 0.9, initialSpringVelocity: 0),
        deleteTiming: Timing = .spring(duration: 0.5, damping: 0.9, initialSpringVelocity: 0),
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.insertTransform = insertTransform
        self.deleteTransform = deleteTransform
        self.insertTiming = insertTiming
        self.updateTiming = updateTiming
        self.deleteTiming = deleteTiming
        self.cascade = cascade
        self.layoutSubviews = layoutSubviews
        self.showInitialInsertionAnimation = showInitialInsertionAnimation
        self.showInsertionAnimationOnOutOfBoundsItems = showInsertionAnimationOnOutOfBoundsItems
    }

    /// Initializes a new animator that uses the same timing configuration for insert, update, and delete.
    /// - Parameters:
    ///   - insertTransform: The 3D transform to apply to the view at the start of insertion animations.
    ///     Defaults to the identity transform.
    ///   - deleteTransform: The 3D transform to apply to the view at the end of deletion animations.
    ///     Defaults to the identity transform.
    ///   - timing: The timing configuration used for insert, delete, and update animations.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        insertTransform: CATransform3D = CATransform3DIdentity,
        deleteTransform: CATransform3D = CATransform3DIdentity,
        timing: Timing,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: insertTransform,
            deleteTransform: deleteTransform,
            insertTiming: timing,
            updateTiming: timing,
            deleteTiming: timing,
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    /// Initializes a new animator with the specified insertion and deletion transforms,
    /// duration, and cascade options.
    /// - Parameters:
    ///   - insertTransform: The 3D transform to apply to the view at the start of insertion animations.
    ///     Defaults to the identity transform.
    ///   - deleteTransform: The 3D transform to apply to the view at the end of deletion animations.
    ///     Defaults to the identity transform.
    ///   - duration: The duration of the animation in seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        insertTransform: CATransform3D = CATransform3DIdentity,
        deleteTransform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: insertTransform,
            deleteTransform: deleteTransform,
            insertTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            updateTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            deleteTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    /// Initializes a new animator that uses the same transform for insertion and deletion.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to both insertion and deletion animations.
    ///   - timing: The timing configuration used for insert, delete, and update animations.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        transform: CATransform3D,
        timing: Timing,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: transform,
            deleteTransform: transform,
            insertTiming: timing,
            updateTiming: timing,
            deleteTiming: timing,
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    /// Initializes a new animator that uses the same transform for insertion and deletion.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to both insertion and deletion animations.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        transform: CATransform3D,
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        layoutSubviews: Bool = true,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.init(
            insertTransform: transform,
            deleteTransform: transform,
            insertTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            updateTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            deleteTiming: .spring(duration: duration, damping: 0.9, initialSpringVelocity: 0),
            cascade: cascade,
            layoutSubviews: layoutSubviews,
            showInitialInsertionAnimation: showInitialInsertionAnimation,
            showInsertionAnimationOnOutOfBoundsItems: showInsertionAnimationOnOutOfBoundsItems,
        )
    }

    public func delete(hostingView: UIView, view: UIView, completion: @escaping () -> Void) {
        if hostingView.componentEngine.isReloading, hostingView.bounds.intersects(view.frame) {
            let baseTransform = view.layer.transform
            deleteTiming.animate(
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
            insertTiming.animate(
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
            updateTiming.animate(
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.center = frame.center
                },
                completion: nil
            )
        }
        if view.bounds.size != frame.bounds.size {
            updateTiming.animate(
                layoutSubviews: layoutSubviews,
                delay: 0,
                animations: {
                    view.bounds.size = frame.bounds.size
                },
                completion: nil
            )
        }
        if view.alpha != 1 {
            updateTiming.animate(
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
