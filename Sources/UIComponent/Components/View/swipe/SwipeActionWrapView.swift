//  Created by y H on 2024/4/11.

import UIKit

class ActionWrapView: UIView {
    var isHighlighted = false {
        didSet { setHighlighted(isHighlighted, transition: .animated(duration: 0.15, curve: .linear)) }
    }

    let highlightedMaskView = UIView()
    let contentView: UIView
    let action: any SwipeAction
    let handlerTap: (any SwipeAction) -> Void
    
    init(action: any SwipeAction, customView: UIView? = nil, handlerTap: @escaping (any SwipeAction) -> Void) {
        self.action = action
        contentView = customView ?? action.view
        self.handlerTap = handlerTap
        super.init(frame: .zero)

        addSubview(contentView)
        addSubview(highlightedMaskView)
        highlightedMaskView.backgroundColor = .clear
        highlightedMaskView.isUserInteractionEnabled = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(_handlerTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHighlighted(_ isHighlighted: Bool, transition: SwipeTransition) {
        transition.update {
            self.highlightedMaskView.backgroundColor = UIColor.black.withAlphaComponent(isHighlighted ? 0.2 : 0)
        }
    }

    @objc private func _handlerTap() {
        handlerTap(action)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        highlightedMaskView.frame = bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.sizeThatFits(size)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }
}

class SwipeActionWrapView: UIView {
    typealias ActionTapHandler = (_ action: any SwipeAction, _ eventForm: SwipeActionEventFrom) -> Void

    let actions: [any SwipeAction]
    let horizontalEdge: SwipeHorizontalEdge
    let config: SwipeConfig
    var preferredWidth: CGFloat {
        contentViewPreferredWidth + sideInset
    }

    var expandedTriggerOffset: CGFloat {
        config.allowsFullSwipe ? (actions.count > 2 ? 40 : 60) : 0
    }

    var isDisplayingExtendedAction: Bool { isExpanded }

    var edgeView: UIView {
        guard let view = isLeft ? views.first : views.last else { fatalError() }
        return view
    }

    var edgeSize: CGFloat {
        guard let size = isLeft ? sizes.first : sizes.last else { fatalError() }
        return size
    }

    var edgeAction: any SwipeAction {
        guard let action = isLeft ? actions.first : actions.last else { fatalError() }
        return action
    }

    let contentViewPreferredWidth: CGFloat
    var clickedAction: (any SwipeAction)? = nil

    private var isLeft: Bool
    private let views: [ActionWrapView]
    private let sizes: [CGFloat]
    private let actionTapHandler: ActionTapHandler
    private var sideInset: CGFloat = 0
    private var offset: CGFloat = 0
    private var alertContext: (action: any SwipeAction, alertWrapView: ActionWrapView)? = nil
    private var isExpanding = false
    private var isExpanded = false
    private var expandedView: UIView?
    private var animator: UIViewPropertyAnimator?
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
  
    init(actions: [any SwipeAction],
        config: SwipeConfig,
        horizontalEdge: SwipeHorizontalEdge,
        actionTapHandler: @escaping ActionTapHandler) {
        let isLeft = horizontalEdge.isLeft
        let actions = isLeft ? actions.reversed() : actions
        let views = actions.map {
            ActionWrapView(action: $0, handlerTap: { actionTapHandler($0, .tap) })
        }
        self.actionTapHandler = actionTapHandler
        let sizes = views.map { floor($0.sizeThatFits(.infinity).width) }
        self.sizes = sizes
        self.views = views
        self.actions = actions
        self.config = config
        self.isLeft = isLeft
        self.contentViewPreferredWidth = sizes.reduce(0) { $0 + $1 }
        self.horizontalEdge = horizontalEdge
        super.init(frame: .zero)
        setup()
    }

    private func setup() {
        (isLeft ? views.reversed() : views).forEach { addSubview($0) }
        clipsToBounds = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeAlert(with action: any SwipeAction, transition: SwipeTransition) {
        guard let index = actions.firstIndex(where: { $0.isSame(action) }) else { return }
        let subview = views[index]
        let alertView = ActionWrapView(action: action, customView: action.makeAlertView()) { [unowned self] in
            actionTapHandler($0, .alert)
            cancelAlert(transition: transition)
        }
        alertView.frame = subview.frame
        addSubview(alertView)
        alertView.layoutIfNeeded()
        UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: nil)
        transition.update {
            alertView.frame = self.bounds
        }
        alertContext = (action, alertView)
    }
    
    func makeExpandedView(with action: any SwipeAction, frame: CGRect) -> UIView? {
        guard let expandedView = action.makeExpandedView() else { return nil }
        expandedView.frame = frame
        insertSubview(expandedView, aboveSubview: edgeView)
        expandedView.layoutIfNeeded()
        isExpanding = true
        if action.isEnableFadeTransitionAddedExpandedView {
            UIView.transition(with: expandedView, duration: 0.1, options: [.transitionCrossDissolve], animations: nil)
        }
        return expandedView
    }
    
    private func cancelAlert(transition: SwipeTransition) {
        guard let alertContext else { return }
        self.alertContext = nil
        transition.update {
            alertContext.alertWrapView.alpha = 0
        } completion: { _ in
            alertContext.alertWrapView.removeFromSuperview()
        }
    }

    func updateOffset(with offset: CGFloat, sideInset: CGFloat, xVelocity: CGFloat, forceSwipeOffset: Bool, anchorAction: (any SwipeAction)?, transition: SwipeTransition) {
        self.sideInset = sideInset
        self.offset = offset
        let factor: CGFloat = abs(offset / preferredWidth)
        let boundarySwipeActionFactor: CGFloat = 1.0 + expandedTriggerOffset / preferredWidth
        
        var totalOffsetX: CGFloat = 0
        var previousFrame = CGRect.zero
        let previousFrames = views.map { $0.frame }
        for (index, (subview, subviewSize)) in zip(views, sizes).enumerated() {
            // layout subviews
            let fixedWidth = subviewSize + (edgeView == subview ? sideInset : 0)
            let offsetX: CGFloat
            if isLeft {
                if config.layoutEffect == .drag {
                    offsetX = index == 0 ? floatInterpolate(factor: min(1, factor), start: -contentViewPreferredWidth, end: 0) : previousFrame.maxX
                } else if config.layoutEffect == .reveal {
                    offsetX = floatInterpolate(factor: min(1, factor), start: previousFrame.minX - (index == 0 ? fixedWidth : -sideInset), end: previousFrame.maxX)
                } else if config.layoutEffect == .static {
                    offsetX = previousFrame.maxX
                } else {
                    fatalError()
                }
            } else {
                if config.layoutEffect == .drag {
                    offsetX = previousFrame.maxX
                } else if config.layoutEffect == .reveal {
                    offsetX = floatInterpolate(factor: min(1, factor), start: previousFrame.minX, end: previousFrame.maxX)
                } else if config.layoutEffect == .static {
                    offsetX = index == 0 ? floatInterpolate(factor: min(1, factor), start: -preferredWidth, end: 0) : previousFrame.maxX
                }  else {
                    fatalError()
                }
            }
            let flexbleWidth = max(fixedWidth, factor * fixedWidth)
            let subviewFrame = CGRect(x: offsetX, y: 0, width: flexbleWidth, height: frame.height)
            transition.update {
                subview.frame = subviewFrame
            }
            previousFrame = subviewFrame
            totalOffsetX += fixedWidth
        }
        let action: (any SwipeAction)?
        var swipeFullTransition = transition
        var isExpanded = false
        if factor > boundarySwipeActionFactor, config.allowsFullSwipe {
            isExpanded = true
            action = anchorAction ?? edgeAction
        } else {
            action = nil
        }

        let expandedViewFrame: CGRect = isExpanded ? CGRect(origin: .zero, size: CGSize(width: offset, height: frame.height)) : edgeView.frame
        if self.isExpanded != isExpanded {
            let makeAnimator = {
                self.animator?.stopAnimation(true)
                let previousExpandedViewFrame = self.expandedView?.frame ?? .zero
                let relativeInitialVelocity = CGVector(dx: SwipeTransitionCurve.relativeVelocity(forVelocity: xVelocity, from: previousExpandedViewFrame.width, to: expandedViewFrame.width), dy: 0)
                let timingParameters = UISpringTimingParameters(damping: 1, response: self.config.defaultTransitionDuration, initialVelocity: relativeInitialVelocity)
                let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
                self.animator = animator
                return animator
            }
            swipeFullTransition = transition.isAnimated ? transition : .animated(duration: 0, curve: .custom(makeAnimator()))
            if expandedView == nil, config.allowsFullSwipe, let action, let index = actions.firstIndex(where: { $0.isSame(action) }) {
                let initialExpandedViewFrame: CGRect
                if forceSwipeOffset {
                    if let alertContext {
                        initialExpandedViewFrame = alertContext.alertWrapView.frame
                    } else {
                        initialExpandedViewFrame = previousFrames[index]
                    }
                } else {
                    initialExpandedViewFrame = views[index].frame
                }
                expandedView = makeExpandedView(with: action, frame: initialExpandedViewFrame)
            }
        }
        handlerExpanded(transition: swipeFullTransition,
                        additive: !transition.isAnimated,
                        expandedViewFrame: expandedViewFrame,
                        isExpanded: isExpanded,
                        anchorAction: action)
        cancelAlert(transition: transition.isAnimated ? transition : .animated(duration: 0.15, curve: .easeInOut))
    }

    func handlerExpanded(transition: SwipeTransition, additive: Bool, expandedViewFrame: CGRect, isExpanded: Bool, anchorAction: (any SwipeAction)?) {
        guard let expandedView, config.allowsFullSwipe else { return }
        var animateAdditive = false
        if additive && transition.isAnimated && self.isExpanded != isExpanded {
            animateAdditive = true
        }
        if animateAdditive {
            if actions.count > 1 {
                transition.updateFrame(with: expandedView, frame: expandedViewFrame)
            }
            if config.feedbackEnable {
                feedbackGenerator.impactOccurred()
                feedbackGenerator.prepare()
            }
        } else {
            transition.updateFrame(with: expandedView, frame: expandedViewFrame)
        }
        self.isExpanded = isExpanded
    }

    func resetExpandedState() {
        guard let expandedView else { return }
        expandedView.removeFromSuperview()
        isExpanding = false
        self.expandedView = nil
        UIView.transition(with: expandedView, duration: 0.1, options: [.transitionCrossDissolve], animations: nil)
    }

    func floatInterpolate(factor: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat {
        return start + (end - start) * factor
    }

    func translateRange(factor: CGFloat, startFactor: CGFloat, endFactor: CGFloat, startValue: CGFloat, endValue: CGFloat) -> CGFloat {
        let factorRange = endFactor - startFactor
        let valueRange = endValue - startValue
        return (factor - startFactor) * valueRange / factorRange + startValue
    }
}
