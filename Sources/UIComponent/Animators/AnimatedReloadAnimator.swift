//  Created by Luke Zhao on 2018-12-27.

import UIKit

public class AnimatedReloadAnimator: Animator {
    public var transform: CATransform3D
    public var duration: TimeInterval
    public var cascade: Bool

    public init(
        transform: CATransform3D = CATransform3DIdentity,
        duration: TimeInterval = 0.5,
        cascade: Bool = false
    ) {
        self.transform = transform
        self.duration = duration
        self.cascade = cascade
        super.init()
    }

    public override func delete(componentView: ComponentDisplayableView, view: UIView, completion: @escaping () -> Void) {
        if componentView.isReloading, componentView.bounds.intersects(view.frame) {
            UIView.animate(
                withDuration: duration,
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

    public override func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
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

    public override func update(componentView _: ComponentDisplayableView, view: UIView, frame: CGRect) {
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
                options: [.allowUserInteraction, .layoutSubviews],
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
