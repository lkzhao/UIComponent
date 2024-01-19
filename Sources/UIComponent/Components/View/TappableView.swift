//  Created by Luke Zhao on 6/8/21.

import UIKit

/// TappableViewConfig is a structure that defines the configuration for a TappableView.
/// It contains closures that can be used to customize the behavior of the view when it is tapped or highlighted.
public struct TappableViewConfig {
    /// The default configuration for all TappableView instances.
    /// This static property is deprecated and you should use `TappableViewConfigEnvironmentKey.defaultValue` instead.
    @available(*, deprecated, message: "Use TappableViewConfigEnvironmentKey.defaultValue instead")
    public static var `default`: TappableViewConfig {
        get {
            TappableViewConfigEnvironmentKey.defaultValue
        }
        set {
            TappableViewConfigEnvironmentKey.defaultValue = newValue
        }
    }

    /// Closure to apply highlight state or animation to the TappableView.
    public var onHighlightChanged: ((TappableView, Bool) -> Void)?

    /// Closure to be called before the actual onTap action is performed.
    public var didTap: ((TappableView) -> Void)?

    /// Initializes a new TappableViewConfig with optional closures for handling highlight changes and tap actions.
    /// - Parameters:
    ///   - onHighlightChanged: A closure that is called when the highlight state changes.
    ///   - didTap: A closure that is called before the onTap action.
    public init(onHighlightChanged: ((TappableView, Bool) -> Void)? = nil, didTap: ((TappableView) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

@available(*, deprecated, message: "Use `TappableViewConfig` instead")
public typealias TappableViewConfiguration = TappableViewConfig

/// TappableView is a subclass of ``ComponentView`` that responds to tap and gesture events.
/// It can be configured using ``TappableViewConfig`` and supports various gestures such as tap, double tap, and long press.
/// 
/// ### Handle Gesture
/// Assign a block to ``onTap``, ``onDoubleTap``, ``onLongPress`` to handle the corresponding gesture.
/// Normally, this class is created by using the ``Component/tappableView(_:)-ew7m`` modifier instead of manually creating an instance.
///
/// ```swift
/// Text("Tap Me").tappableView { view in
///      print("Tapped")
/// }.onLongPress { (view, gesture) in
///      if gesture.state == .began {
///          print("Long pressed")
///      }
/// }
/// ```
///
/// ### Display Context Menu
/// TappableView supports long press context menu. Simply assign a ``contextMenuProvider`` and return a ``UIMenu`` to be displayed.
/// ```swift
/// Text("Show Menu").tappableView {
/// }.contextMenuProvider {
///     UIMenu(...) // return the menu you want to be displayed
/// }
/// ```
///
/// ### Handle Drop
/// TappableView supports acting as a drop target. Simply assign a ``dropDelegate`` and handle the corresponding drop events.
/// ```swift
/// Text("Drop Here").tappableView {
/// }.dropDelegate(yourDropDelegate)
/// ```
/// For more advanced drag and drop support, please create a custom View.
///
/// ### Pointer Style
/// TappableView supports pointer style on iPadOS. Simply assign a ``pointerStyleProvider`` and return a ``UIPointerStyle`` to be displayed.
/// ```swift
/// Text("Show Pointer").tappableView {
/// }.pointerStyleProvider {
///    UIPointerStyle(...) // return the pointer style you want to be displayed
/// }
open class TappableView: ComponentView {
    /// The configuration object for the TappableView, which defines the behavior of the view when it is tapped or highlighted.
    public var config: TappableViewConfig?

    /// Deprecated: Use `config` instead.
    @available(*, deprecated, message: "Use `config` instead")
    public var configuration: TappableViewConfig? {
        get { config }
        set { config = newValue }
    }

    /// A gesture recognizer for detecting single taps on the TappableView.
    public private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    
    /// A gesture recognizer for detecting double taps on the TappableView.
    public private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    /// A gesture recognizer for detecting long presses on the TappableView.
    public private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
    
    #if !os(tvOS)
    /// An interaction object for managing the context menu in response to force touch or long press gestures.
    public private(set) lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)
    #endif

    /// The background color to be used for the preview when the TappableView is used in a context menu.
    public var previewBackgroundColor: UIColor?
    
    /// A closure that is called when the TappableView is tapped.
    public var onTap: ((TappableView) -> Void)? {
        didSet {
            if onTap != nil {
                addGestureRecognizer(tapGestureRecognizer)
            } else {
                removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    /// A closure that is called when a long press gesture is recognized on the TappableView.
    public var onLongPress: ((TappableView, UILongPressGestureRecognizer) -> Void)? {
        didSet {
            if onLongPress != nil {
                addGestureRecognizer(longPressGestureRecognizer)
            } else {
                removeGestureRecognizer(longPressGestureRecognizer)
            }
        }
    }

    /// A closure that is called when the TappableView is double-tapped.
    public var onDoubleTap: ((TappableView) -> Void)? {
        didSet {
            if onDoubleTap != nil {
                addGestureRecognizer(doubleTapGestureRecognizer)
            } else {
                removeGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }

#if !os(tvOS)
    /// The interaction responsible for handling drop operations on the TappableView.
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

    /// A closure that provides a preview view controller to be displayed when the TappableView is used in a context menu.
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

    /// A closure that provides a context menu to be displayed when the TappableView is long-pressed.
    /// Setting this property will add a context menu interaction if it's not already present.
    public var contextMenuProvider: ((TappableView) -> UIMenu?)? {
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

    /// A closure that provides a pointer style when the TappableView is hovered over with a pointer device.
    /// Available only on iOS 13.4 and later.
    @available(iOS 13.4, *)
    public var pointerStyleProvider: (() -> UIPointerStyle?)? {
        get { _pointerStyleProvider as? () -> UIPointerStyle? }
        set { _pointerStyleProvider = newValue }
    }
#endif

    /// A Boolean value that determines whether the TappableView is in a highlighted state.
    /// Changes to this property can trigger an update to the view's appearance.
    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            config?.onHighlightChanged?(self, isHighlighted)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityTraits = .button
    #if !os(tvOS)
        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
    #endif
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    /// Called when a tap is recognized.
    @objc open func didTap() {
        config?.didTap?(self)
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
}

#if !os(tvOS)
@available(iOS 13.4, *)
extension TappableView: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        if let pointerStyleProvider {
            return pointerStyleProvider()
        } else {
            return UIPointerStyle(effect: .automatic(UITargetedPreview(view: self)), shape: nil)
        }
    }
}

extension TappableView: UIContextMenuInteractionDelegate {
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
