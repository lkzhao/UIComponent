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

    /// Initializes a new animator with the specified transform, duration, and cascade options.
    /// - Parameters:
    ///   - transform: The 3D transform to apply to the view during animation. Defaults to the identity transform.
    ///   - duration: The duration of the animation in seconds. Defaults to 0.5 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    public init(
        transform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval = 0.5,
        cascade: Bool = false
    ) {
        self.transform = transform
        self.duration = duration
        self.cascade = cascade
    }

    public func delete(componentView: ComponentDisplayableView, view: UIView, completion: @escaping () -> Void) {
        if componentView.isReloading, componentView.bounds.intersects(view.frame) {
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
                    if !componentView.visibleViews.contains(view) {
                        view.transform = CGAffineTransform.identity
                        view.alpha = 1
                    }
                    completion()
                }
            )
        } else {
            completion()
        }
    }

    public func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        view.bounds.size = frame.size
        view.center = frame.center
        if componentView.isReloading, componentView.hasReloaded, componentView.bounds.intersects(frame) {
            let offsetTime: TimeInterval = cascade ? TimeInterval(frame.origin.distance(componentView.bounds.origin) / 3000) : 0
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
                    view.transform = .identity
                    view.alpha = 1
                }
            )
        }
    }

    public func update(componentView _: ComponentDisplayableView, view: UIView, frame: CGRect) {
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
        if view.alpha != 1 || view.transform != .identity {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.transform = .identity
                    view.alpha = 1
                },
                completion: nil
            )
        }
    }
}
