//  Created by y H on 2024/4/7.

import UIKit

public struct SwipeConfig {
    
    public static var `default`: SwipeConfig = SwipeConfig()
    
    public enum LayoutEffect {
        case reveal
        case drag
        case `static`
    }

    public var allowsFullSwipe: Bool
    
    public var edgeBackgroundIgnoreSafeAreaInset: Bool

    public var feedbackEnable: Bool

    public var rubberBandEnable: Bool
    /// By using an exponent between 0 and 1, the view’s offset is moved less the further it is away from its resting position. Use a larger exponent for less movement and a smaller exponent for more movement.
    public var rubberBandFactor: CGFloat

    public var layoutEffect: LayoutEffect
    
    public var gap: CGFloat
    public var spacing: CGFloat

    public var defaultTransitionCurve: SwipeTransitionCurve
    public var defaultTransitionDuration: TimeInterval
    
    public var cornerRadius: CGFloat
    public var clipsToBounds: Bool
  
    public init(allowsFullSwipe: Bool = true, 
                edgeBackgroundIgnoreSafeAreaInset: Bool = true,
                feedbackEnable: Bool = true,
                rubberBandEnable: Bool = true,
                rubberBandFactor: CGFloat = 0.90,
                layoutEffect: LayoutEffect = .static,
                gap: CGFloat = 0,
                spacing: CGFloat = 0,
                cornerRadius: CGFloat = 0,
                clipsToBounds: Bool = true,
                defaultTransitionCurve: SwipeTransitionCurve = .easeInOut,
                defaultTransitionDuration: TimeInterval = 0.25) {
        self.allowsFullSwipe = allowsFullSwipe
        self.edgeBackgroundIgnoreSafeAreaInset = edgeBackgroundIgnoreSafeAreaInset
        self.feedbackEnable = feedbackEnable
        self.rubberBandEnable = rubberBandEnable
        self.rubberBandFactor = rubberBandFactor
        self.layoutEffect = layoutEffect
        self.gap = gap
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBounds
        self.defaultTransitionCurve = defaultTransitionCurve
        self.defaultTransitionDuration = defaultTransitionDuration
    }
}

public class SwipeView: UIView {
    
    public var actions: [any SwipeAction] {
        set { configActions(with: newValue) }
        get { _actions }
    }

    public var config: SwipeConfig = .init() {
        didSet { updateConfig() }
    }

    let contentView = ComponentView()

    /// The component that is rendered within the `contentView`.
    public var component: (any Component)? {
        get { contentView.component }
        set { contentView.component = newValue }
    }

    // MARK: privates props

    private lazy var panRecognizer = SwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(_:)))

    private var scrollView: UIScrollView? { sequence(first: superview, next: { $0?.superview }).compactMap { $0 as? UIScrollView }.first }

    private var observation: NSKeyValueObservation?

    private var revealOffset: CGFloat = 0.0
    
    private var initialRevealOffset: CGFloat = 0.0

    private var leftActions: [any SwipeAction] = []

    private var rightActions: [any SwipeAction] = []

    private var _actions: [any SwipeAction] = []

    private var leftSwipeActionsContainerView: SwipeActionWrapView? = nil

    private var rightSwipeActionsContainerView: SwipeActionWrapView? = nil

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.frame.origin = .zero
        panRecognizer.delegate = self
        panRecognizer.allowAnyDirection = true
        gestureRecognizers = [panRecognizer]
        updateConfig()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame.size = bounds.size
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.sizeThatFits(size)
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil, let scrollView else { return }
        observation?.invalidate()
        observation = nil
        observation = scrollView.observe(\.contentOffset) { [weak self] _, _ in
            guard let self else { return }
            closeSwipeAction(transition: .animated(duration: config.defaultTransitionDuration, curve: config.defaultTransitionCurve))
        }
    }
    
    func updateConfig() {
        clipsToBounds = config.clipsToBounds
    }

    func defaultTransitionCurve(xVelocity: CGFloat, from: CGFloat, to: CGFloat) -> SwipeTransitionCurve {
        let relativeInitialVelocity = CGVector(dx: SwipeTransitionCurve.relativeVelocity(forVelocity: xVelocity, from: from, to: to), dy: 0)
        let timingParameters = UISpringTimingParameters(damping: 1, response: config.defaultTransitionDuration, initialVelocity: relativeInitialVelocity)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        return .custom(animator)
    }
    
    func configActions(with actions: [any SwipeAction]) {
        let leftActions = actions.filter { $0.horizontalEdge == .left }
        let rightActions = actions.filter { $0.horizontalEdge == .right }
        guard !self.actions.elementsEqual(actions, by: { $0.isSame($1) }) else {
            _actions = actions
            self.leftActions = leftActions
            self.rightActions = rightActions
            return
        }
        let wasEmpty = self.leftActions.isEmpty && self.rightActions.isEmpty
        let isEmpty = leftActions.isEmpty && rightActions.isEmpty
        _actions = actions
        self.leftActions = leftActions
        self.rightActions = rightActions
        if leftActions.isEmpty {
            if leftSwipeActionsContainerView != nil {
                panRecognizer.becomeCancelled()
                updateRevealOffsetInternal(offset: 0.0, xVelocity: 0, transition: .animated(duration: config.defaultTransitionDuration, curve: config.defaultTransitionCurve), anchorAction: nil)
            }
        }
        if rightActions.isEmpty {
            if rightSwipeActionsContainerView != nil {
                panRecognizer.becomeCancelled()
                updateRevealOffsetInternal(offset: 0.0, xVelocity: 0, transition: .animated(duration: config.defaultTransitionDuration, curve: config.defaultTransitionCurve), anchorAction: nil)
            }
        }
        if wasEmpty != isEmpty {
            panRecognizer.isEnabled = !isEmpty
        }
    }

    @objc func swipeGesture(_ recognizer: SwipeGestureRecognizer) {
        let xVelocity = recognizer.velocity(in: self).x
        switch recognizer.state {
        case .began:
            closeOtherSwipeAction(transition: .animated(duration: config.defaultTransitionDuration, curve: config.defaultTransitionCurve))
            initialRevealOffset = revealOffset
        case .changed:
            var translation = recognizer.translation(in: self)
            translation.x += initialRevealOffset
            if leftActions.isEmpty {
                let offsetX = pow(abs(translation.x), 0.7)
                translation.x = min(offsetX, translation.x)
            }
            if rightActions.isEmpty {
                let offsetX = -pow(abs(translation.x), 0.7)
                translation.x = max(offsetX, translation.x)
            }
            if leftSwipeActionsContainerView == nil && CGFloat(0.0).isLess(than: translation.x) {
                setupLeftActionsContainerView()
            } else if rightSwipeActionsContainerView == nil && translation.x.isLess(than: 0.0) {
                setupRightActionsContainerView()
            }
            updateRevealOffsetInternal(offset: translation.x, xVelocity: xVelocity, transition: .immediate, anchorAction: nil)
        case .cancelled, .ended:
            if let leftSwipeActionsContainerView {
                let containerViewSize = CGSize(width: leftSwipeActionsContainerView.preferredWidth + config.spacing, height: frame.height)
                var reveal = false
                if abs(xVelocity) < 100.0 {
                    if initialRevealOffset.isZero && revealOffset > 0.0 {
                        reveal = true
                    } else if revealOffset > containerViewSize.width {
                        reveal = true
                    } else {
                        reveal = false
                    }
                } else {
                    if xVelocity > 0.0 {
                        reveal = true
                    } else {
                        reveal = false
                    }
                }
                if reveal && leftSwipeActionsContainerView.isDisplayingExtendedAction {
                    reveal = false
                    handlerActionEvent(action: leftSwipeActionsContainerView.edgeAction, actionsContainerView: leftSwipeActionsContainerView, eventFrom: .expanded)
                } else {
                    updateRevealOffsetInternal(offset: reveal ? containerViewSize.width : 0.0,
                                               xVelocity: xVelocity,
                                               transition: .animated(duration: 0, curve: defaultTransitionCurve(xVelocity: xVelocity, from: revealOffset, to: containerViewSize.width)),
                                               anchorAction: nil) {
//                        guard recognizer.state != .changed else { return }
                        leftSwipeActionsContainerView.resetExpandedState()
                    }
                }
            } else if let rightSwipeActionsContainerView {
                let containerViewSize = CGSize(width: rightSwipeActionsContainerView.preferredWidth + config.spacing, height: frame.height)
                var reveal = false
                if abs(xVelocity) < 100.0 {
                    if initialRevealOffset.isZero && revealOffset < 0.0 {
                        reveal = true
                    } else if revealOffset < -containerViewSize.width {
                        reveal = true
                    } else {
                        reveal = false
                    }
                } else {
                    if xVelocity < 0.0 {
                        reveal = true
                    } else {
                        reveal = false
                    }
                }
                if reveal && rightSwipeActionsContainerView.isDisplayingExtendedAction {
                    reveal = false
                    handlerActionEvent(action: rightSwipeActionsContainerView.edgeAction, actionsContainerView: rightSwipeActionsContainerView, eventFrom: .expanded)
                } else {
                    updateRevealOffsetInternal(offset: reveal ? -containerViewSize.width : 0.0, 
                                               xVelocity: xVelocity,
                                               transition: .animated(duration: 0, curve: defaultTransitionCurve(xVelocity: xVelocity, from: revealOffset, to: -containerViewSize.width)),
                                               anchorAction: nil) {
//                        guard recognizer.state != .changed else { return }
                        rightSwipeActionsContainerView.resetExpandedState()
                    }
                }
            } else {
                updateRevealOffsetInternal(offset: 0, xVelocity: xVelocity, transition: .animated(duration: 0, curve: defaultTransitionCurve(xVelocity: xVelocity, from: revealOffset, to: 0)), anchorAction: nil)
            }
        default: break
        }
    }

    func updateRevealOffsetInternal(offset: CGFloat, xVelocity: CGFloat, transition: SwipeTransition, forceSwipeOffset: Bool = false, anchorAction: (any SwipeAction)?, completion: (() -> Void)? = nil) {
        revealOffset = offset
        var leftRevealCompleted = true
        var rightRevealCompleted = true
        let intermediateCompletion = {
            if leftRevealCompleted && rightRevealCompleted {
                completion?()
            }
        }
        transition.updateOriginX(with: contentView, originX: offset)
        if let leftSwipeActionsContainerView {
            leftRevealCompleted = false
            let containerViewSize = CGSize(width: leftSwipeActionsContainerView.preferredWidth, height: frame.height)
            let completion = {
                if CGFloat(offset).isLessThanOrEqualTo(0.0) {
                    leftSwipeActionsContainerView.removeFromSuperview()
                }
                leftRevealCompleted = true
                intermediateCompletion()
            }
            if CGFloat(offset).isLessThanOrEqualTo(0.0) {
                self.leftSwipeActionsContainerView = nil
                if config.rubberBandEnable && !forceSwipeOffset {
                    transition.updateOriginX(with: contentView, originX: offset)
                }
            } else {
                if config.rubberBandEnable && !forceSwipeOffset {
                    var distance: CGFloat {
                        let w = containerViewSize.width + leftSwipeActionsContainerView.expandedTriggerOffset
                        return offset - (offset >= w ? pow(offset - w, config.rubberBandFactor) : 0)
                    }
                    let distanceOffsetX = offset >= containerViewSize.width ? distance : offset
                    transition.updateOriginX(with: contentView, originX: distanceOffsetX)
                    
                }
            }
            let containerViewFrame = CGRect(origin: .zero, size: CGSize(width: max(0, contentView.frame.minX - config.spacing), height: containerViewSize.height))
            transition.updateFrame(with: leftSwipeActionsContainerView, frame: containerViewFrame) {
                guard $0 else { return }
                completion()
            }
            leftSwipeActionsContainerView.updateOffset(with: contentView.frame.minX - config.spacing,
                                                       sideInset: safeAreaInsets.left,
                                                       xVelocity: xVelocity,
                                                       forceSwipeOffset: forceSwipeOffset,
                                                       anchorAction: anchorAction,
                                                       transition: transition)
        }
        if let rightSwipeActionsContainerView {
            rightRevealCompleted = false
            let containerViewSize = CGSize(width: rightSwipeActionsContainerView.preferredWidth, height: frame.height)
            let completion = {
                if CGFloat(0.0).isLessThanOrEqualTo(offset) {
                    rightSwipeActionsContainerView.removeFromSuperview()
                }
                rightRevealCompleted = true
                intermediateCompletion()
            }
            if CGFloat(0.0).isLessThanOrEqualTo(offset) {
                self.rightSwipeActionsContainerView = nil
                if config.rubberBandEnable && !forceSwipeOffset {
                    transition.updateOriginX(with: contentView, originX: offset)
                }
            } else {
                if config.rubberBandEnable && !forceSwipeOffset {
                    var distance: CGFloat {
                        let w = containerViewSize.width + rightSwipeActionsContainerView.expandedTriggerOffset
                        return offset + (-offset >= w ? pow((-offset) - w, config.rubberBandFactor) : 0)
                    }
                    let distanceOffsetX = -offset >= containerViewSize.width ? distance : offset
                    transition.updateOriginX(with: contentView, originX: distanceOffsetX)
                }
            }
            let containerViewFrame = CGRect(origin: CGPoint(x: frame.width - abs(contentView.frame.minX) + config.spacing, y: 0),
                                            size: CGSize(width: max(0, abs(contentView.frame.minX) - config.spacing), height: containerViewSize.height))
            transition.updateFrame(with: rightSwipeActionsContainerView, frame: containerViewFrame) {
                guard $0 else { return }
                completion()
            }
            rightSwipeActionsContainerView.updateOffset(with: abs(contentView.frame.minX) - config.spacing,
                                                        sideInset: safeAreaInsets.right,
                                                        xVelocity: xVelocity,
                                                        forceSwipeOffset: forceSwipeOffset,
                                                        anchorAction: anchorAction,
                                                        transition: transition)
        }
    }

    func setupLeftActionsContainerView() {
        if !leftActions.isEmpty {
            let actionsContainerView = SwipeActionWrapView(actions: leftActions, config: config, horizontalEdge: .left) { [weak self] action, event in
                guard let self, let leftSwipeActionsContainerView else { return }
                handlerActionEvent(action: action, actionsContainerView: leftSwipeActionsContainerView, eventFrom: event)
            }
            leftSwipeActionsContainerView = actionsContainerView
            let size = CGSize(width: actionsContainerView.preferredWidth, height: bounds.height)
            actionsContainerView.frame = CGRect(origin: CGPoint(x: min(revealOffset - size.width, 0.0), y: 0.0), size: size)
            actionsContainerView.updateOffset(with: 0,
                                              sideInset: safeAreaInsets.left,
                                              xVelocity: 0,
                                              forceSwipeOffset: false,
                                              anchorAction: nil,
                                              transition: .immediate)
            actionsContainerView.actions.forEach { $0.willShow() }
            insertSubview(actionsContainerView, belowSubview: contentView)
        }
    }

    func setupRightActionsContainerView() {
        if !rightActions.isEmpty {
            let actionsContainerView = SwipeActionWrapView(actions: rightActions, config: config, horizontalEdge: .right) { [weak self] action, event in
                guard let self, let rightSwipeActionsContainerView else { return }
                handlerActionEvent(action: action, actionsContainerView: rightSwipeActionsContainerView, eventFrom: event)
            }
            rightSwipeActionsContainerView = actionsContainerView
            let size = CGSize(width: actionsContainerView.preferredWidth, height: bounds.height)
            actionsContainerView.frame = CGRect(origin: CGPoint(x: bounds.width + max(revealOffset, -size.width), y: 0.0), size: size)
            actionsContainerView.updateOffset(with: 0,
                                              sideInset: safeAreaInsets.right,
                                              xVelocity: 0,
                                              forceSwipeOffset: false,
                                              anchorAction: nil,
                                              transition: .immediate)
            actionsContainerView.actions.forEach { $0.willShow() }
            insertSubview(actionsContainerView, belowSubview: contentView)
        }
    }

    func handlerActionEvent(action: any SwipeAction, actionsContainerView: SwipeActionWrapView, eventFrom: SwipeActionEventFrom) {
        action.handlerAction(completion: { [weak self] afterHandler in
            guard let self else { return }
            self.afterHandler(with: afterHandler, action: action)
        }, eventFrom: eventFrom)
    }
    
    func afterHandler(with afterHandler: SwipeActionAfterHandler, action: (any SwipeAction)?) {
        let defaultTransition = SwipeTransition.animated(duration: config.defaultTransitionDuration, curve: config.defaultTransitionCurve)
        guard let action, let actionWrapViewView = action.wrapView else {
            closeSwipeAction(transition: defaultTransition)
            return
        }
        switch afterHandler {
        case .close:
            closeSwipeAction(transition: defaultTransition)
        case let .swipeFull(completion):
            let xVelocity = panRecognizer.lastVelocity.x
            actionWrapViewView.clickedAction = action
            let offset = frame.width + config.spacing
            let relativeInitialVelocity = CGVector(dx: SwipeTransitionCurve.relativeVelocity(forVelocity: xVelocity, from: offset, to: actionWrapViewView.horizontalEdge.isLeft ? offset : -offset), dy: 0)
            let timingParameters = UISpringTimingParameters(damping: 1, response: config.defaultTransitionDuration, initialVelocity: relativeInitialVelocity)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            updateRevealOffsetInternal(
                offset: actionWrapViewView.horizontalEdge.isLeft ? offset : -offset,
                xVelocity: xVelocity,
                transition: .animated(duration: 0, curve: .custom(animator)),
                forceSwipeOffset: true,
                anchorAction: action
            ) {
                completion?()
                self.updateRevealOffsetInternal(offset: 0, xVelocity: 0, transition: .immediate, anchorAction: nil)
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: nil)
            }
        case .alert:
            updateRevealOffsetInternal(offset: action.horizontalEdge.isLeft ? actionWrapViewView.preferredWidth : -actionWrapViewView.preferredWidth, xVelocity: 0, transition: defaultTransition, anchorAction: nil)
            actionWrapViewView.makeAlert(with: action, transition: defaultTransition)
        case .hold:
            updateRevealOffsetInternal(offset: action.horizontalEdge.isLeft ? actionWrapViewView.preferredWidth : -actionWrapViewView.preferredWidth, xVelocity: 0, transition: defaultTransition, anchorAction: nil)
        }
    }
    
    public func closeOtherSwipeAction(transition: SwipeTransition) {
        guard let scrollView else { return }
        let views = scrollView.allSubViewsOf(type: Self.self).filter { $0 != self }
        guard !views.isEmpty else { return }
        views.forEach { $0.closeSwipeAction(transition: transition) }
    }

    public func closeSwipeAction(transition: SwipeTransition) {
        updateRevealOffsetInternal(offset: 0.0, xVelocity: 0, transition: transition, anchorAction: nil)
    }

    deinit {
        observation?.invalidate()
        observation = nil
    }
}

extension SwipeView: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer, panRecognizer.numberOfTouches == 0 {
            let translation = panRecognizer.velocity(in: panRecognizer.view)
            if abs(translation.y) > 4.0 && abs(translation.y) > abs(translation.x) * 2.5 {
                return false
            }
        }
        return true
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == panRecognizer {
            return true
        } else {
            return false
        }
    }
}

final class SwipeGestureRecognizer: UIPanGestureRecognizer {
    public var validatedGesture = false
    public var firstLocation = CGPoint()

    public var allowAnyDirection = false
    public var lastVelocity = CGPoint()

    override public init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        if #available(iOS 13.4, *) {
            self.allowedScrollTypesMask = .continuous
        }

        maximumNumberOfTouches = 1
    }

    override public func reset() {
        super.reset()

        validatedGesture = false
    }

    public func becomeCancelled() {
        state = .cancelled
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first!
        firstLocation = touch.location(in: view)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let location = touches.first!.location(in: view)
        let translation = CGPoint(x: location.x - firstLocation.x, y: location.y - firstLocation.y)

        if !validatedGesture {
            if !allowAnyDirection && translation.x > 0.0 {
                state = .failed
            } else if abs(translation.y) > 4.0 && abs(translation.y) > abs(translation.x) * 2.5 {
                state = .failed
            } else if abs(translation.x) > 4.0 && abs(translation.y) * 2.5 < abs(translation.x) {
                validatedGesture = true
            }
        }

        if validatedGesture {
            lastVelocity = velocity(in: view)
            super.touchesMoved(touches, with: event)
        }
    }
}

private extension UIView {
    func allSubViewsOf<T: UIView>(type _: T.Type) -> [T] {
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach { getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}
