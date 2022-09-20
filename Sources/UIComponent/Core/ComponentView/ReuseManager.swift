//  Created by Luke Zhao on 2017-07-21.

import UIKit

open class ReuseManager: NSObject {
    public static let shared = ReuseManager()

    /// Time it takes for ReuseManager to
    /// dump all reusableViews to save memory
    public var lifeSpan: TimeInterval = 5.0

    /// When `removeFromSuperviewWhenReuse` is enabled,
    /// cells will always be removed from ComponentView during reuse.
    /// This is slower but it doesn't influence the `isHidden` property
    /// of individual cells.
    public var removeFromSuperviewWhenReuse = true

    var reusableViews: [String: [UIView]] = [:]
    var cleanupTimer: Timer?

    public func enqueue<T: UIView>(identifier: String = NSStringFromClass(T.self), view: T) {
        view.ckContext.reuseIdentifier = nil
        view.ckContext.reuseManager = nil
        if removeFromSuperviewWhenReuse {
            view.removeFromSuperview()
        } else {
            view.isHidden = true
        }
        if reusableViews[identifier] != nil, !reusableViews[identifier]!.contains(view) {
            reusableViews[identifier]?.append(view)
        } else {
            reusableViews[identifier] = [view]
        }
        if let cleanupTimer {
            cleanupTimer.fireDate = Date().addingTimeInterval(lifeSpan)
        } else {
            cleanupTimer = Timer.scheduledTimer(
                timeInterval: lifeSpan,
                target: self,
                selector: #selector(cleanup),
                userInfo: nil,
                repeats: false
            )
        }
    }

    public func dequeue<T: UIView>(
        identifier: String = NSStringFromClass(T.self),
        _ defaultView: @autoclosure () -> T
    ) -> T {
        let queuedView = reusableViews[identifier]?.popLast() as? T
        let view = queuedView ?? defaultView()
        if !removeFromSuperviewWhenReuse {
            view.isHidden = false
        }
        view.ckContext.reuseManager = self
        view.ckContext.reuseIdentifier = identifier
        return view
    }

    public func dequeue<T: UIView>(
        identifier: String = NSStringFromClass(T.self),
        type: T.Type
    ) -> T {
        return dequeue(identifier: identifier, type.init())
    }

    @objc func cleanup() {
        for views in reusableViews.values {
            for view in views {
                view.removeFromSuperview()
            }
        }
        reusableViews.removeAll()
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }
}
