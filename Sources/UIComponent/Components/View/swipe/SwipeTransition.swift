//  Created by y H on 2024/4/11.

import UIKit

public enum SwipeTransition {
    case immediate
    case animated(duration: TimeInterval, curve: SwipeTransitionCurve)

    var isAnimated: Bool {
        if case .immediate = self {
            return false
        } else {
            return true
        }
    }
}

public enum SwipeTransitionCurve: Equatable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case spring(damping: CGFloat, initialVelocity: CGVector)
    case custom(UIViewPropertyAnimator)

    func animator(duration: TimeInterval) -> UIViewPropertyAnimator {
        switch self {
        case .linear:
            return UIViewPropertyAnimator(duration: duration, curve: .linear)
        case .easeInOut:
            return UIViewPropertyAnimator(duration: duration, curve: .easeInOut)
        case .easeIn:
            return UIViewPropertyAnimator(duration: duration, curve: .easeIn)
        case .easeOut:
            return UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        case let .spring(damping, initialVelocity):
            return UIViewPropertyAnimator(duration: duration, timingParameters: UISpringTimingParameters(dampingRatio: damping, initialVelocity: initialVelocity))
        case let .custom(animator):
            return animator
        }
    }

    var timingFunction: CAMediaTimingFunctionName? {
        switch self {
        case .linear:
            return CAMediaTimingFunctionName.linear
        case .easeInOut:
            return CAMediaTimingFunctionName.easeInEaseOut
        case .easeIn:
            return CAMediaTimingFunctionName.easeIn
        case .easeOut:
            return CAMediaTimingFunctionName.easeOut
        case .spring:
            return nil
        case .custom:
            return nil
        }
    }
}

extension SwipeTransition {
    func animatePositionAdditive(with view: UIView, offset: CGPoint, removeOnCompletion: Bool = false, completion: ((Bool) -> Void)? = nil) {
        switch self {
        case .immediate:
            completion?(true)
        case let .animated(duration, curve):
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = NSValue(cgPoint: offset)
            animation.toValue = NSValue(cgPoint: CGPoint())
            animation.isAdditive = true
            animation.isRemovedOnCompletion = removeOnCompletion
            animation.fillMode = .forwards
            if let timingFunction = curve.timingFunction {
                animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
            }
            animation.duration = duration
            animation.delegate = CALayerAnimationDelegate(animation: animation, completion: completion)
            animation.speed = 1.0
            view.layer.add(animation, forKey: "position")
        }
    }
    
    @discardableResult
    func update(animation: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) -> UIViewPropertyAnimator? {
        switch self {
        case .immediate:
            animation()
            if let completion = completion {
                completion(true)
            }
        case let .animated(duration, curve):
            let animator = curve.animator(duration: duration)
            animator.addAnimations(animation)
            animator.addCompletion { position in
                if let completion = completion {
                    completion(position == .end)
                }
            }
            animator.startAnimation()
            return animator
        }
        return nil
    }

    func updateOriginX(with view: UIView, originX: CGFloat, completion _: ((Bool) -> Void)? = nil) {
        update { view.frame.origin.x = originX }
    }

    func updateFrame(with view: UIView, frame: CGRect, completion: ((Bool) -> Void)? = nil) {
        if view.frame.equalTo(frame) {
            completion?(true)
        } else {
            update(animation: {
                view.frame = frame
            }, completion: completion)
        }
    }
}

private class CALayerAnimationDelegate: NSObject, CAAnimationDelegate {
    private let keyPath: String?
    var completion: ((Bool) -> Void)?
    
    init(animation: CAAnimation, completion: ((Bool) -> Void)?) {
        if let animation = animation as? CABasicAnimation {
            self.keyPath = animation.keyPath
        } else {
            self.keyPath = nil
        }
        self.completion = completion
        
        super.init()
    }
    
    @objc func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let anim = anim as? CABasicAnimation {
            if anim.keyPath != self.keyPath {
                return
            }
        }
        if let completion = self.completion {
            completion(flag)
            self.completion = nil
        }
    }
}
