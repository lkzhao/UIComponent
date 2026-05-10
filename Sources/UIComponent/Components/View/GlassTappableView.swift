//  Created by Luke Zhao on 5/6/26.

/// GlassTappableViewConfig is a structure that defines the configuration for a GlassTappableView.
/// It contains closures that can be used to customize the behavior of the view when it is tapped or highlighted.
public struct GlassTappableViewConfig {
    /// The default configuration for all GlassTappableView instances.
    public static var `default`: GlassTappableViewConfig = GlassTappableViewConfig(onHighlightChanged: nil, didTap: nil)

    /// Closure to apply highlight state or animation to the GlassTappableView.
    public var onHighlightChanged: ((GlassTappableView, Bool) -> Void)?

    /// Closure to be called before the actual onTap action is performed.
    public var didTap: ((GlassTappableView) -> Void)?

    /// Initializes a new GlassTappableViewConfig with optional closures for handling highlight changes and tap actions.
    /// - Parameters:
    ///   - onHighlightChanged: A closure that is called when the highlight state changes.
    ///   - didTap: A closure that is called before the onTap action.
    public init(onHighlightChanged: ((GlassTappableView, Bool) -> Void)? = nil, didTap: ((GlassTappableView) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

/// GlassTappableView is a visual effect view that responds to tap and gesture events.
/// On iOS 26 and later, it uses an interactive ``UIGlassEffect``. On earlier iOS versions,
/// it falls back to the system material blur effect.
///
/// Normally, this class is created by using the ``Component/glassTappableView(_:)-9c1d0`` modifier instead of manually creating an instance.
open class GlassTappableView: UIVisualEffectView {
    /// The configuration object for the GlassTappableView, which defines the behavior of the view when it is tapped or highlighted.
    public var config: GlassTappableViewConfig?

    /// A gesture recognizer for detecting single taps on the GlassTappableView.
    public private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))

    /// A gesture recognizer for immediate press/highlight state.
    public private(set) lazy var highlightGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didChangeHighlight))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        return gesture
    }()

    /// A gesture recognizer for detecting double taps on the GlassTappableView.
    public private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    #if !os(tvOS)
    /// A interaction for managing spring loading on the GlassTappableView.
    public private(set) lazy var springLoadedInteraction = UISpringLoadedInteraction { [weak self] interaction, context in
        guard let self else { return }
        self.onSpringLoaded?(self)
    }
    #endif

    /// A gesture recognizer for detecting long presses on the GlassTappableView.
    public private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))

    #if !os(tvOS)
    /// An interaction object for managing the context menu in response to force touch or long press gestures.
    public private(set) lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)
    #endif

    /// The background color to be used for the preview when the GlassTappableView is used in a context menu.
    public var previewBackgroundColor: UIColor?

    /// A closure that is called when the GlassTappableView is tapped.
    public var onTap: ((GlassTappableView) -> Void)? {
        didSet {
            if onTap != nil {
                addGestureRecognizer(tapGestureRecognizer)
            } else {
                removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    /// A closure that is called when a long press gesture is recognized on the GlassTappableView.
    public var onLongPress: ((GlassTappableView, UILongPressGestureRecognizer) -> Void)? {
        didSet {
            if onLongPress != nil {
                addGestureRecognizer(longPressGestureRecognizer)
            } else {
                removeGestureRecognizer(longPressGestureRecognizer)
            }
        }
    }

    /// A closure that is called when the GlassTappableView is double-tapped.
    public var onDoubleTap: ((GlassTappableView) -> Void)? {
        didSet {
            if onDoubleTap != nil {
                addGestureRecognizer(doubleTapGestureRecognizer)
            } else {
                removeGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }

    #if !os(tvOS)
    /// A closure that is called when the GlassTappableView is spring loaded.
    public var onSpringLoaded: ((GlassTappableView) -> Void)? {
        didSet {
            if onSpringLoaded != nil {
                addInteraction(springLoadedInteraction)
            } else {
                removeInteraction(springLoadedInteraction)
            }
        }
    }

    /// The interaction responsible for handling drop operations on the GlassTappableView.
    private var dropInteraction: UIDropInteraction?

    /// The delegate that responds to drop interaction events.
    /// Setting a new delegate will replace any existing drop interaction with a new one using the provided delegate.
    public weak var dropDelegate: UIDropInteractionDelegate? {
        didSet {
            guard dropDelegate !== oldValue else { return }
            if let dropDelegate {
                dropInteraction = UIDropInteraction(delegate: dropDelegate)
                addInteraction(dropInteraction!)
            } else {
                if let dropInteraction {
                    removeInteraction(dropInteraction)
                }
            }
        }
    }

    /// A closure that provides a preview view controller to be displayed when the GlassTappableView is used in a context menu.
    /// Setting this property will add a context menu interaction if it's not already present.
    public var previewProvider: (() -> UIViewController?)? {
        didSet {
            if previewProvider != nil || contextMenuProvider != nil {
                addInteraction(contextMenuInteraction)
            } else {
                removeInteraction(contextMenuInteraction)
            }
        }
    }

    /// A closure that is called when the context menu preview is committed.
    public var onCommitPreview: ((UIContextMenuInteractionCommitAnimating) -> Void)?

    /// A closure that provides a context menu to be displayed when the GlassTappableView is long-pressed.
    /// Setting this property will add a context menu interaction if it's not already present.
    public var contextMenuProvider: ((GlassTappableView) -> UIMenu?)? {
        didSet {
            if previewProvider != nil || contextMenuProvider != nil {
                addInteraction(contextMenuInteraction)
            } else {
                removeInteraction(contextMenuInteraction)
            }
        }
    }

    /// A type-erased pointer style provider.
    private var _pointerStyleProvider: Any?

    /// A closure that provides a pointer style when the GlassTappableView is hovered over with a pointer device.
    /// Available only on iOS 13.4 and later.
    @available(iOS 13.4, *)
    public var pointerStyleProvider: (() -> UIPointerStyle?)? {
        get { _pointerStyleProvider as? () -> UIPointerStyle? }
        set { _pointerStyleProvider = newValue }
    }
    #endif

    /// A Boolean value that determines whether the GlassTappableView is in a highlighted state.
    /// Changes to this property can trigger an update to the view's appearance.
    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            (config ?? .default).onHighlightChanged?(self, isHighlighted)
        }
    }

    #if os(tvOS)
    open override var canBecomeFocused: Bool {
        onTap != nil
    }
    #endif

    public init(frame: CGRect) {
        super.init(effect: Self.defaultEffect())
        self.frame = frame
        configure()
    }

    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect ?? Self.defaultEffect())
        configure()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func defaultEffect() -> UIVisualEffect {
        if #available(iOS 26.0, tvOS 26.0, macCatalyst 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.isInteractive = true
            return effect
        }

        #if os(tvOS)
        return UIBlurEffect(style: .regular)
        #else
        return UIBlurEffect(style: .systemMaterial)
        #endif
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

    #if os(tvOS)
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        let isFocused = context.nextFocusedView === self
        isHighlighted = isFocused

        guard (config ?? .default).onHighlightChanged == nil else { return }
        coordinator.addCoordinatedAnimations {
            self.transform = isFocused ? CGAffineTransform(scaleX: 1.06, y: 1.06) : .identity
            self.layer.shadowOpacity = isFocused ? 0.28 : 0
            self.layer.shadowRadius = isFocused ? 18 : 0
            self.layer.shadowOffset = CGSize(width: 0, height: isFocused ? 10 : 0)
            self.layer.shadowColor = UIColor.black.cgColor
        }
    }

    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if onTap != nil, presses.contains(where: { $0.type == .select }) {
            didTap()
            return
        }
        super.pressesEnded(presses, with: event)
    }
    #endif

    /// Called when a tap is recognized.
    @objc open func didTap() {
        (config ?? .default).didTap?(self)
        onTap?(self)
    }

    /// Called when a double tap is recognized.
    @objc open func didDoubleTap() {
        onDoubleTap?(self)
    }

    /// Called when a long press is recognized.
    @objc open func didLongPress() {
        onLongPress?(self, longPressGestureRecognizer)
    }

    private func configure() {
        isUserInteractionEnabled = true
        accessibilityTraits = .button
        addGestureRecognizer(highlightGestureRecognizer)
        #if !os(tvOS)
        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
        #endif
    }

    @objc open func didChangeHighlight() {
        switch highlightGestureRecognizer.state {
        case .began, .changed:
            isHighlighted = bounds.contains(highlightGestureRecognizer.location(in: self))
        case .ended, .cancelled, .failed:
            isHighlighted = false
        default:
            break
        }
    }
}

extension GlassTappableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer === highlightGestureRecognizer || otherGestureRecognizer === highlightGestureRecognizer
    }
}

#if !os(tvOS)
@available(iOS 13.4, *)
extension GlassTappableView: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        if let pointerStyleProvider {
            return pointerStyleProvider()
        } else {
            return UIPointerStyle(effect: .automatic(UITargetedPreview(view: self)), shape: nil)
        }
    }
}

extension GlassTappableView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let previewProvider {
            return UIContextMenuConfiguration(identifier: nil) {
                previewProvider()
            } actionProvider: { [weak self] _ in
                guard let self else { return nil }
                return self.contextMenuProvider?(self)
            }
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                guard let self else { return nil }
                return self.contextMenuProvider?(self)
            }
        }
    }

    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration config: UIContextMenuConfiguration)
        -> UITargetedPreview?
    {
        if let previewBackgroundColor {
            let param = UIPreviewParameters()
            param.backgroundColor = previewBackgroundColor
            return UITargetedPreview(view: self, parameters: param)
        }
        return nil
    }

    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willPerformPreviewActionForMenuWith config: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        if let onCommitPreview {
            onCommitPreview(animator)
        } else {
            animator.addAnimations {
                self.onTap?(self)
            }
        }
    }
}
#endif
