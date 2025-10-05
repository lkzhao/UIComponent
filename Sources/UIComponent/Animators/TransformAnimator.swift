//  Created by Luke Zhao on 2018-12-27.

import UIKit

@available(*, deprecated, renamed: "TransformAnimator")
public typealias AnimatedReloadAnimator = TransformAnimator

/// A simple Animator implementation that applies a transform and fade
/// animation during deletion and insertion.
public struct TransformAnimator: Animator {
    /// The 3D transform applied to the view during animation.
    public var transform: CATransform3D
    /// The duration of the animation in seconds.
    public var duration: TimeInterval
    /// A Boolean value that determines whether the animation should be applied in a cascading manner.
    public var cascade: Bool
    /// A Boolean value that determines whether to show the initial insertion animation when the view is first loaded.
    public var showInitialInsertionAnimation: Bool = false
    /// A Boolean value that determines whether to show insertion animations for items that are out of the bounds of the hosting view.
    public var showInsertionAnimationOnOutOfBoundsItems: Bool = false

    /// Initializes a new animator with the specified transform, duration, and cascade options.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to the view during animation. Defaults to the identity transform.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    public init(
        transform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval = 0.5,
        cascade: Bool = false,
        showInitialInsertionAnimation: Bool = false,
        showInsertionAnimationOnOutOfBoundsItems: Bool = false,
    ) {
        self.transform = transform
        self.duration = duration
        self.cascade = cascade
        self.showInitialInsertionAnimation = showInitialInsertionAnimation
        self.showInsertionAnimationOnOutOfBoundsItems = showInsertionAnimationOnOutOfBoundsItems
    }

    public func delete(hostingView: UIView, view: UIView, completion: @escaping () -> Void) {
        if hostingView.componentEngine.isReloading, hostingView.bounds.intersects(view.frame) {
            let baseTransform = view.layer.transform
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.layer.transform = self.transform
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
                view.layer.transform = transform
                view.alpha = 0
            }
            UIView.animate(
                withDuration: duration,
                delay: offsetTime,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.layer.transform = baseTransform
                    view.alpha = 1
                }
            )
        }
    }

    public func update(hostingView _: UIView, view: UIView, frame: CGRect) {
        if view.center != frame.center {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.center = frame.center
                },
                completion: nil
            )
        }
        if view.bounds.size != frame.bounds.size {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.bounds.size = frame.bounds.size
                },
                completion: nil
            )
        }
        if view.alpha != 1 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.alpha = 1
                },
                completion: nil
            )
        }
    }
}
