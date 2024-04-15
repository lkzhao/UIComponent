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
        config.allowsFullSwipe && config.layoutEffect == .flexble ? actions.count > 2 ? 50 : 80 : 0
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
    private let contentView = UIView()
    private let views: [ActionWrapView]
    private let sizes: [CGFloat]
    private let actionTapHandler: ActionTapHandler
    private var sideInset: CGFloat = 0
    private var offset: CGFloat = 0
    private var alertContext: (action: any SwipeAction, alertWrapView: ActionWrapView)? = nil
    private var expandedViewExtraFixedWidth: CGFloat { 400 }
    private var isExpanded = false
    private var isExpandedViewAdded = false
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var expandedView: UIView? = {
        guard let view = edgeAction.makeExpandedView() else { return nil }
        view.frame = CGRect(origin: CGPoint(x: isLeft ? -expandedViewExtraFixedWidth : (contentViewPreferredWidth - edgeSize), y: 0), size: CGSize(width: edgeSize + expandedViewExtraFixedWidth, height: frame.height))
        contentView.insertSubview(view, belowSubview: contentView)
        return view
    }()
  
    init(
        actions: [any SwipeAction],
        config: SwipeConfig,
        horizontalEdge: SwipeHorizontalEdge,
        actionTapHandler: @escaping ActionTapHandler
    ) {
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
        contentViewPreferredWidth = sizes.reduce(0) { $0 + $1 }
        self.horizontalEdge = horizontalEdge
        super.init(frame: .zero)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        addSubview(contentView)
        (isLeft ? views.reversed() : views).forEach { contentView.addSubview($0) }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeAlert(with action: any SwipeAction, transition: SwipeTransition) async {
        guard let index = actions.firstIndex(where: { $0.isSame(action) }) else { return }
        let subview = views[index]
        let alertView = ActionWrapView(action: action, customView: action.makeAlertView()) { [unowned self] in
            actionTapHandler($0, .alert)
            cancelAlert(transition: transition)
        }
        alertView.frame = subview.frame
        contentView.addSubview(alertView)
        UIView.transition(with: self.contentView, duration: 0.2, options: [.transitionCrossDissolve], animations: nil)
        try? await Task.sleep(nanoseconds: 1)
        transition.update {
            alertView.frame = self.contentView.bounds
        }
        alertContext = (action, alertView)
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

    func updateOffset(with offset: CGFloat, sideInset: CGFloat, forceSwipeOffset: Bool, shouldForceSwipeFull: Bool, transition: SwipeTransition) {
        self.sideInset = sideInset
        self.offset = offset
        let contentViewFixedWidth = floor(contentViewPreferredWidth)
        let sideInsetFactor: CGFloat = sideInset == 0 ? 0 : abs(offset / sideInset)
        let factor: CGFloat
        if horizontalEdge == .right && offset <= contentViewFixedWidth + sideInset {
            factor = abs(offset / (contentViewFixedWidth + sideInset))
        } else {
            factor = abs(max(0, offset - sideInset) / contentViewFixedWidth)
        }
        let boundarySwipeActionFactor: CGFloat = 1.0 + expandedTriggerOffset / preferredWidth

        let contentViewFlexbleSize = max(0, max(contentViewFixedWidth, offset - sideInset))
        var contentViewOffsetX: CGFloat {
            if isLeft {
                if sideInset.isZero {
                    return sideInset
                } else {
                    return min(floatInterpolate(factor: sideInsetFactor, start: 0, end: sideInset), sideInset)
                }
            } else {
                return 0
            }
        }
        transition.updateFrame(with: contentView, frame: CGRect(x: contentViewOffsetX, y: 0, width: contentViewFlexbleSize, height: bounds.height))

        var totalOffsetX: CGFloat = 0
        for (subview, subviewSize) in zip(views, sizes) {
            // layout subviews
            let fixedSize = subviewSize
            let flexbleSize = floatInterpolate(factor: factor, start: 0, end: fixedSize)
            let finalWidth = (config.layoutEffect == .flexble && !forceSwipeOffset) ? max(fixedSize, flexbleSize) : fixedSize
            var subviewOffsetX: CGFloat {
                let start = isLeft ? factor >= 1 ? 0 : -finalWidth : 0
                let x: CGFloat
                if config.layoutEffect == .flexble && !forceSwipeOffset {
                    x = floatInterpolate(factor: factor, start: start, end: totalOffsetX)
                } else {
                    if forceSwipeOffset {
                        x = isLeft ? max(0, offset - finalWidth) : totalOffsetX
                    } else {
                        x = totalOffsetX
                    }
                }
                return x
            }
            transition.update { [weak self] in
                guard let self else { return }
                subview.frame = CGRect(x: subviewOffsetX, y: 0, width: finalWidth, height: contentView.frame.height)
            }
            totalOffsetX += fixedSize
        }
        var swipeFullTransition = transition
        var isExpanded = false
        var extendedWidth: CGFloat {
            if isExpanded {
                return max(contentViewFixedWidth, contentViewFlexbleSize)
            } else {
                return isLeft ? edgeSize * factor : contentViewFlexbleSize
            }
        }
        if factor > boundarySwipeActionFactor, config.allowsFullSwipe {
            isExpanded = true
        }
        if self.isExpanded != isExpanded {
            swipeFullTransition = transition.isAnimated ? transition : .animated(duration: 0.2, curve: .easeInOut)
        }
        handlerExpanded(transition: swipeFullTransition, additive: !transition.isAnimated, extendedWidth: extendedWidth, isExpanded: isExpanded, shouldForceSwipeFull: shouldForceSwipeFull, forceSwipeOffset: forceSwipeOffset)
        cancelAlert(transition: transition.isAnimated ? transition : .animated(duration: 0.15, curve: .easeInOut))
    }

    func handlerExpanded(transition: SwipeTransition, additive: Bool, extendedWidth: CGFloat, isExpanded: Bool, shouldForceSwipeFull: Bool, forceSwipeOffset: Bool) {
        guard let expandedView, config.allowsFullSwipe, config.layoutEffect == .flexble else { return }
        var animateAdditive = false
        if (additive ? additive : shouldForceSwipeFull) && transition.isAnimated && self.isExpanded != isExpanded {
            animateAdditive = true
        } else if transition.isAnimated && self.isExpanded != isExpanded && additive == false && !shouldForceSwipeFull && forceSwipeOffset {
            expandedView.isHidden = true
            UIView.transition(with: contentView, duration: 0.15, options: [.transitionCrossDissolve], animations: nil)
        }
        let expandedViewFrame: CGRect
        if isLeft {
            expandedViewFrame = CGRect(origin: CGPoint(x: isLeft ? -expandedViewExtraFixedWidth : 0.0, y: 0.0), size: CGSize(width: isLeft ? extendedWidth + expandedViewExtraFixedWidth : extendedWidth, height: frame.height))
        } else {
            expandedViewFrame = CGRect(origin: CGPoint(x: isExpanded ? 0 : edgeView.frame.minX, y: 0), size: CGSize(width: extendedWidth + sideInset, height: frame.height))
        }

        if animateAdditive {
            if expandedView.tag == 0, isLeft {
                expandedView.frame.size = CGSize(width: edgeView.frame.width + expandedViewExtraFixedWidth, height: expandedView.frame.height)
            }
            let previousFrame = isLeft ? expandedView.frame : expandedView.tag == 0 ? edgeView.frame : expandedView.frame
            expandedView.tag = 1 // for mark first
            expandedView.frame = expandedViewFrame
            if actions.count > 1 {
                contentView.insertSubview(expandedView, aboveSubview: edgeView)
            }
            var deltaX: CGFloat {
                if isLeft {
                    return (shouldForceSwipeFull && forceSwipeOffset) ? 0 : previousFrame.width - expandedViewFrame.width
                } else {
                    return previousFrame.minX - expandedViewFrame.minX
                }
            }
            if actions.count > 1 {
                transition.animatePositionAdditive(with: expandedView, offset: CGPoint(x: deltaX, y: 0))
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
        contentView.sendSubviewToBack(expandedView)
        expandedView.isHidden = false
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
