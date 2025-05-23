//  Created by Luke Zhao on 2017-07-21.

import UIKit

public protocol ReuseableView: UIView {
    func prepareForReuse()
}

/// `ReuseManager` is a class that manages the reuse of `UIView` objects to improve performance.
/// It stores reusable views in a dictionary and provides methods to enqueue and dequeue these views.
/// It also handles the cleanup of views that are no longer needed.
open class ReuseManager: NSObject {
    /// Shared instance of `ReuseManager`.
    public static let shared = ReuseManager()

    /// The time interval after which the reusable views are cleaned up.
    public var lifeSpan: TimeInterval = 5.0

    /// A Boolean value that determines whether a view should be removed from its superview when it is enqueued for reuse.
    public var removeFromSuperviewWhenReuse = true

    /// A dictionary that maps identifiers to arrays of reusable `UIView` objects.
    var reusableViews: [String: [UIView]] = [:]
    /// An optional `Timer` that triggers the cleanup of reusable views.
    var cleanupTimer: Timer?

    /// Enqueues a `UIView` for reuse by adding it to the `reusableViews` dictionary.
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies the type of the view.
    ///   - view: The `UIView` to be enqueued.
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

    /// Dequeues a reusable `UIView` if available, or creates a new one using the provided closure.
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies the type of the view.
    ///   - defaultView: A closure that creates a new instance of the view if no reusable view is available.
    /// - Returns: A `UIView` that is either dequeued from the reusable views or created anew.
    public func dequeue<T: UIView>(
        identifier: String = NSStringFromClass(T.self),
        _ defaultView: @autoclosure () -> T
    ) -> T {
        let queuedView = reusableViews[identifier]?.popLast() as? T
        let view = queuedView ?? defaultView()
        view.layer.removeAllAnimations()
        (view as? ReuseableView)?.prepareForReuse()
        if !removeFromSuperviewWhenReuse {
            view.isHidden = false
        }
        view.ckContext.reuseManager = self
        view.ckContext.reuseIdentifier = identifier
        return view
    }

    /// Dequeues a reusable `UIView` if available, or creates a new one by initializing the provided type.
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies the type of the view.
    ///   - type: The type of the view to be dequeued or created.
    /// - Returns: A `UIView` that is either dequeued from the reusable views or created anew.
    public func dequeue<T: UIView>(
        identifier: String = NSStringFromClass(T.self),
        type: T.Type
    ) -> T {
        return dequeue(identifier: identifier, type.init())
    }

    /// Cleans up all reusable views by removing them from their superview and clearing the `reusableViews` dictionary.
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
