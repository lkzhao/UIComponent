//  Created by Luke Zhao on 2017-07-19.

@_implementationOnly import BaseToolbox
import UIKit

open class Animator {

    public init() {}

    /// Called before ComponentView perform any update to the cells.
    /// This method is only called when your animator is the componentView's root animator (i.e. componentView.animator)
    ///
    /// - Parameters:
    ///   - componentView: the ComponentView performing the update
    open func willUpdate(componentView: ComponentDisplayableView) {}

    /// Called when ComponentView inserts a view into its subviews.
    ///
    /// Perform any insertion animation when needed
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being inserted
    ///   - frame: frame provided by the layout
    open func insert(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    ) {}

    /// Called when ComponentView deletes a view from its subviews.
    ///
    /// Perform any deletion animation, then call `enqueue(view: view)`
    /// after the animation finishes
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being deleted
    open func delete(
        componentView: ComponentDisplayableView,
        view: UIView,
        completion: @escaping () -> Void
    ) {
        completion()
    }

    /// Called when:
    ///   * the view has just been inserted
    ///   * the view's frame changed after `reloadData`
    ///   * the view's screen position changed when user scrolls
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being updated
    ///   - frame: frame provided by the layout
    open func update(
        componentView: ComponentDisplayableView,
        view: UIView,
        frame: CGRect
    ) {
        if view.bounds.size != frame.bounds.size {
            view.bounds.size = frame.bounds.size
        }
        if view.center != frame.center {
            view.center = frame.center
        }
    }

    /// Called when contentOffset changes during reloadData
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - delta: changes in contentOffset
    ///   - view: the view being updated
    open func shift(componentView: ComponentDisplayableView, delta: CGPoint, view: UIView) {
        view.center += delta
    }
}
