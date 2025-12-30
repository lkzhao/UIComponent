//  Created by Luke Zhao on 2017-07-19.

/// `Animator` is a base class that provides default implementations for animations
/// related to the insertion, deletion, and updating of views.
/// Subclasses can override these methods to provide custom animation behavior.
public protocol Animator {

    /// Called before the component engine perform any update to the cells.
    /// This method is only called when your animator is the `ComponentEngine`'s root animator (i.e. `componentEngine.animator`)
    ///
    /// - Parameters:
    ///   - hostingView: source view that is performing the update
    func willUpdate(hostingView: PlatformView)

    /// Called when the component engine inserts a view into its subviews.
    ///
    /// Perform any insertion animation when needed
    ///
    /// - Parameters:
    ///   - hostingView: source view that host the component
    ///   - view: the view being inserted
    ///   - frame: frame provided by the layout
    func insert(
        hostingView: PlatformView,
        view: PlatformView,
        frame: CGRect
    )

    /// Called when the component engine deletes a view from its subviews.
    ///
    /// Perform any deletion animation, then call the `completion` block when finished.
    ///
    /// - Parameters:
    ///   - hostingView: source view that host the component
    ///   - view: the view being deleted
    ///   - completion: call this block when finished
    func delete(
        hostingView: PlatformView,
        view: PlatformView,
        completion: @escaping () -> Void
    )

    /// Called when:
    ///   * the view has just been inserted
    ///   * the view's frame changed after `reloadData`
    ///   * the view's screen position changed when user scrolls
    ///
    /// - Parameters:
    ///   - hostingView: source view that host the component
    ///   - view: the view being updated
    ///   - frame: frame provided by the layout
    func update(
        hostingView: PlatformView,
        view: PlatformView,
        frame: CGRect
    )

    /// Called when contentOffset changes during reloadData
    ///
    /// - Parameters:
    ///   - hostingView: source view that host the component
    ///   - delta: changes in contentOffset
    ///   - view: the view being updated
    func shift(hostingView: PlatformView, delta: CGPoint, view: PlatformView)
}

// MARK: - Default implementation

public extension Animator {
    func willUpdate(hostingView: PlatformView) {}
    func insert(
        hostingView: PlatformView,
        view: PlatformView,
        frame: CGRect
    ) {}
    func delete(
        hostingView: PlatformView,
        view: PlatformView,
        completion: @escaping () -> Void
    ) {
        completion()
    }
    func update(
        hostingView: PlatformView,
        view: PlatformView,
        frame: CGRect
    ) {
        if view.bounds.size != frame.size {
            view.bounds.size = frame.size
        }
        if view.center != frame.center {
            view.center = frame.center
        }
    }
    func shift(hostingView: PlatformView, delta: CGPoint, view: PlatformView) {
        view.center += delta
    }
}

/// A simple animator that does nothing
public struct BaseAnimator: Animator {
    public init() {}
}
