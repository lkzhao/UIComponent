//  Created by Luke Zhao on 2026-03-20.

/// A simple `Animator` implementation that applies a fade animation during
/// deletion and insertion without animating updates.
public struct FadeAnimator: Animator {
    /// The duration of the animation in seconds.
    public var duration: TimeInterval
    /// A Boolean value that determines whether the animation should be applied in a cascading manner.
    public var cascade: Bool
    /// A Boolean value that determines whether to show the initial insertion animation when the view is first loaded.
    public var showInitialInsertionAnimation: Bool = false
    /// A Boolean value that determines whether to animate items that are out of the bounds of the hosting view.
    public var animateOutOfBoundsItems: Bool = false

    /// Initializes a new animator with the specified duration and cascade options.
    /// - Parameters:
    ///   - duration: The duration of the animation in seconds. Defaults to 0.3 seconds.
    ///   - cascade: A Boolean value that determines whether the animation should be applied in a cascading manner. Defaults to `false`.
    ///   - layoutSubviews: A Boolean value that determines whether animation blocks include the `.layoutSubviews` option. Defaults to `true`.
    public init(
        duration: TimeInterval = 0.3,
        cascade: Bool = false,
        showInitialInsertionAnimation: Bool = false,
        animateOutOfBoundsItems: Bool = false,
    ) {
        self.duration = duration
        self.cascade = cascade
        self.showInitialInsertionAnimation = showInitialInsertionAnimation
        self.animateOutOfBoundsItems = animateOutOfBoundsItems
    }

    public func delete(hostingView: UIView, view: UIView, completion: @escaping () -> Void) {
        if hostingView.componentEngine.isReloading,
           animateOutOfBoundsItems || hostingView.bounds.intersects(view.frame) {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.allowUserInteraction],
                animations: {
                    view.alpha = 0
                },
                completion: { _ in
                    if !hostingView.componentEngine.visibleViews.contains(view) {
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
        if hostingView.componentEngine.isReloading,
           showInitialInsertionAnimation || hostingView.componentEngine.hasReloaded,
           animateOutOfBoundsItems || hostingView.bounds.intersects(frame) {
            let offsetTime: TimeInterval = cascade ? TimeInterval(frame.origin.distance(hostingView.bounds.origin) / 3000) : 0
            UIView.performWithoutAnimation {
                view.alpha = 0
            }
            UIView.animate(
                withDuration: duration,
                delay: offsetTime,
                options: [.allowUserInteraction],
                animations: {
                    view.alpha = 1
                }
            )
        }
    }
}
