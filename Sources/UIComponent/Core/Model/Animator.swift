//  Created by Luke Zhao on 2017-07-19.


import UIKit

/// Animator is a base class that provides default implementations for animations
/// related to the insertion, deletion, and updating of views within a `ComponentDisplayableView`.
/// Subclasses can override these methods to provide custom animation behavior.
public protocol Animator {

    /// Called before ComponentView perform any update to the cells.
    /// This method is only called when your animator is the componentView's root animator (i.e. componentView.animator)
    ///
    /// - Parameters:
    ///   - componentView: the ComponentView performing the update
    func willUpdate(componentView: ComponentDisplayableView)

    /// Called when ComponentView inserts a view into its subviews.
    ///
    /// Perform any insertion animation when needed
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being inserted
    ///   - frame: frame provided by the layout
    func insert(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    )

    /// Called when ComponentView deletes a view from its subviews.
    ///
    /// Perform any deletion animation, then call the `completion` block when finished.
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being deleted
    ///   - completion: call this block when finished
    func delete(
        componentView: ComponentDisplayableView,
        view: UIView,
        completion: @escaping () -> Void
    )

    /// Called when:
    ///   * the view has just been inserted
    ///   * the view's frame changed after `reloadData`
    ///   * the view's screen position changed when user scrolls
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being updated
    ///   - frame: frame provided by the layout
    func update(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    )

    /// Called when contentOffset changes during reloadData
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - delta: changes in contentOffset
    ///   - view: the view being updated
    func shift(componentView: ComponentDisplayableView, delta: CGPoint, view: UIView)
}

// MARK: - Default implementation

public extension Animator {
    func willUpdate(componentView: ComponentDisplayableView) {}
    func insert(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    ) {}
    func delete(
        componentView: ComponentDisplayableView,
        view: UIView,
        completion: @escaping () -> Void
    ) {
        completion()
    }
    func update(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    ) {
        if view.bounds.size != frame.size {
            view.bounds.size = frame.size
        }
        if view.center != frame.center {
            view.center = frame.center
        }
    }
    func shift(componentView: ComponentDisplayableView, delta: CGPoint, view: UIView) {
        view.center += delta
    }
}

/// A simple animator that does nothing
public struct BaseAnimator: Animator {
    public init() {}
}
