//  Created by Luke Zhao on 2018-12-27.

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

#if canImport(UIKit)
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
#else
    private func frameFromBoundsAndCenter(size: CGSize, center: CGPoint) -> CGRect {
        CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    private func runMacAnimation(
        duration: TimeInterval,
        delay: TimeInterval,
        animations: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        let run = {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animations()
            } completionHandler: {
                completion()
            }
        }

        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                run()
            }
        } else {
            run()
        }
    }

    public func delete(hostingView: PlatformView, view: PlatformView, completion: @escaping () -> Void) {
        let shouldAnimate = hostingView.componentEngine.isReloading && hostingView.bounds.intersects(view.frame)
        guard shouldAnimate else {
            completion()
            return
        }

        view.wantsLayer = true
        let baseTransform = view.layer?.transform ?? CATransform3DIdentity
        let baseAlpha = view.alphaValue

        runMacAnimation(duration: duration, delay: 0, animations: {
            if let layer = view.layer {
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
                layer.transform = self.transform
                CATransaction.commit()
            }
            view.animator().alphaValue = 0
        }, completion: {
            if !hostingView.componentEngine.visibleViews.contains(view) {
                view.layer?.transform = baseTransform
                view.alphaValue = baseAlpha
            }
            completion()
        })
    }

    public func insert(hostingView: PlatformView, view: PlatformView, frame: CGRect) {
        view.frame = frameFromBoundsAndCenter(size: frame.size, center: frame.center)

        let shouldAnimate = hostingView.componentEngine.isReloading
            && (showInitialInsertionAnimation || hostingView.componentEngine.hasReloaded)
            && (showInsertionAnimationOnOutOfBoundsItems || hostingView.bounds.intersects(frame))

        guard shouldAnimate else {
            view.wantsLayer = true
            view.layer?.transform = CATransform3DIdentity
            view.alphaValue = 1
            return
        }

        view.wantsLayer = true
        let baseTransform = view.layer?.transform ?? CATransform3DIdentity
        let offsetTime: TimeInterval = cascade ? TimeInterval(frame.origin.distance(hostingView.bounds.origin) / 3000) : 0

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        view.layer?.transform = transform
        CATransaction.commit()
        view.alphaValue = 0

        runMacAnimation(duration: duration, delay: offsetTime, animations: {
            if let layer = view.layer {
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
                layer.transform = baseTransform
                CATransaction.commit()
            }
            view.animator().alphaValue = 1
        }, completion: {})
    }

    public func update(hostingView _: PlatformView, view: PlatformView, frame: CGRect) {
        let targetFrame = frameFromBoundsAndCenter(size: frame.size, center: frame.center)

        let shouldAnimate = view.frame != targetFrame || view.alphaValue != 1
        guard shouldAnimate else { return }

        runMacAnimation(duration: duration, delay: 0, animations: {
            view.animator().frame = targetFrame
            view.animator().alphaValue = 1
        }, completion: {})
    }
#endif
}
