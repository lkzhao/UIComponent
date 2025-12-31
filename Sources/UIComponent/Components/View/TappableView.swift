//  Created by Luke Zhao on 6/8/21.

/// TappableViewConfig is a structure that defines the configuration for a TappableView.
/// It contains closures that can be used to customize the behavior of the view when it is tapped or highlighted.
public struct TappableViewConfig {
    /// The default configuration for all TappableView instances.
    public static var `default`: TappableViewConfig = TappableViewConfig(onHighlightChanged: nil, didTap: nil)

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

@available(*, deprecated, renamed: "TappableViewConfig")
public typealias TappableViewConfiguration = TappableViewConfig

/// TappableView is view that respond to tap and gesture events.
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
#if canImport(UIKit)
open class TappableView: PlatformView {
    /// The configuration object for the TappableView, which defines the behavior of the view when it is tapped or highlighted.
    public var config: TappableViewConfig?

    /// Deprecated: Use `config` instead.
    @available(*, deprecated, renamed: "config")
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

    /// A interaction for managing spring loading on the TappableView.
    public private(set) lazy var springLoadedInteraction = UISpringLoadedInteraction { [weak self] interaction, context in
        guard let self else { return }
        self.onSpringLoaded?(self)
    }

    /// A gesture recognizer for detecting long presses on the TappableView.
    public private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
    
    #if !os(tvOS)
    /// An interaction object for managing the context menu in response to force touch or long press gestures.
    public private(set) lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)
    #endif

    /// The background color to be used for the preview when the TappableView is used in a context menu.
    public var previewBackgroundColor: PlatformColor?
    
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
    public var onLongPress: ((TappableView, PlatformLongPressGesture) -> Void)? {
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

    /// A closure that is called when the TappableView is spring loaded.
    public var onSpringLoaded: ((TappableView) -> Void)? {
        didSet {
            if onSpringLoaded != nil {
                addInteraction(springLoadedInteraction)
            } else {
                removeInteraction(springLoadedInteraction)
            }
        }
    }

#if !os(tvOS)
    /// The interaction responsible for handling drop operations on the TappableView.
    private var legacyDropInteraction: UIDropInteraction?
    private var platformDropInteraction: UIDropInteraction?

    /// The delegate that responds to drop interaction events.
    /// Setting a new delegate will replace any existing drop interaction with a new one using the provided delegate.
    @available(*, deprecated, message: "Use dropTypes and onDragEntered/onDragUpdated/onDragExited/onPerformDrop instead.")
    public weak var dropDelegate: UIDropInteractionDelegate? {
        didSet {
            guard dropDelegate !== oldValue else { return }
            if let dropDelegate {
                legacyDropInteraction = UIDropInteraction(delegate: dropDelegate)
                addInteraction(legacyDropInteraction!)
            } else {
                if let legacyDropInteraction {
                    removeInteraction(legacyDropInteraction)
                }
            }
        }
    }

    private var hasPlatformDropHandlers: Bool {
        !dropTypes.isEmpty || onDragEntered != nil || onDragUpdated != nil || onDragExited != nil || onPerformDrop != nil
    }

    private func updatePlatformDropInteraction() {
        guard hasPlatformDropHandlers else {
            if let platformDropInteraction {
                removeInteraction(platformDropInteraction)
                self.platformDropInteraction = nil
            }
            return
        }

        if platformDropInteraction == nil {
            platformDropInteraction = UIDropInteraction(delegate: self)
            addInteraction(platformDropInteraction!)
        }
    }

    /// The uniform type identifiers this view accepts for drops (UTType identifiers).
    public var dropTypes: [String] = [] {
        didSet {
            guard dropTypes != oldValue else { return }
            updatePlatformDropInteraction()
        }
    }

    public var onDragEntered: ((TappableView, PlatformDropInfo) -> PlatformDropOperation)?
    public var onDragUpdated: ((TappableView, PlatformDropInfo) -> PlatformDropOperation)?
    public var onDragExited: ((TappableView, PlatformDropInfo) -> Void)?
    public var onPerformDrop: ((TappableView, PlatformDropInfo) -> Bool)?

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
    public var contextMenuProvider: ((TappableView) -> PlatformMenu?)? {
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
    /// On macOS, this is an `NSCursor`.
    @available(iOS 13.4, *)
    public var pointerStyleProvider: (() -> PlatformPointerStyle?)? {
        get { _pointerStyleProvider as? () -> PlatformPointerStyle? }
        set { _pointerStyleProvider = newValue }
    }
#endif

    /// A Boolean value that determines whether the TappableView is in a highlighted state.
    /// Changes to this property can trigger an update to the view's appearance.
    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            (config ?? .default).onHighlightChanged?(self, isHighlighted)
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

extension TappableView: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard !dropTypes.isEmpty else { return false }
        return session.hasItemsConforming(toTypeIdentifiers: dropTypes)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        let info = PlatformDropInfo(interaction: interaction, session: session)
        _ = onDragEntered?(self, info)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let info = PlatformDropInfo(interaction: interaction, session: session)
        let operation = onDragUpdated?(self, info) ?? .copy
        return UIDropProposal(operation: operation)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        let info = PlatformDropInfo(interaction: interaction, session: session)
        onDragExited?(self, info)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let info = PlatformDropInfo(interaction: interaction, session: session)
        _ = onPerformDrop?(self, info)
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

#elseif os(macOS)
/// A macOS implementation of `TappableView` that supports tap and highlight behavior.
open class TappableView: PlatformView {
    private var trackingAreaToken: NSTrackingArea?
    private var longPressWorkItem: DispatchWorkItem?
    private var didTriggerLongPress = false
    private var didPushCursor = false
    private var isControlClick = false
    private var activeLongPressGesture: PlatformLongPressGesture?
    private var pressLocationInView: CGPoint?

    deinit {
        if didPushCursor {
            NSCursor.pop()
        }
        if let trackingAreaToken {
            removeTrackingArea(trackingAreaToken)
        }
    }

    /// A closure that provides a context menu to be displayed when the TappableView is right-clicked or long-pressed.
    public var contextMenuProvider: ((TappableView) -> PlatformMenu?)?

    /// A closure that is called when the view is long-pressed (click-and-hold).
    public var onLongPress: ((TappableView, PlatformLongPressGesture) -> Void)?

    /// A closure that provides a cursor when the view is hovered.
    public var pointerStyleProvider: (() -> PlatformPointerStyle?)?

    /// The pasteboard types this view accepts for drop.
    /// Setting this to a non-empty array registers the view as a drop destination.
    public var dropTypes: [String] = [] {
        didSet {
            guard dropTypes != oldValue else { return }
            if dropTypes.isEmpty {
                unregisterDraggedTypes()
            } else {
                registerForDraggedTypes(dropTypes.map { NSPasteboard.PasteboardType(rawValue: $0) })
            }
        }
    }

    /// Called when a drag enters the view.
    public var onDragEntered: ((TappableView, PlatformDropInfo) -> PlatformDropOperation)?

    /// Called when a drag updates within the view.
    public var onDragUpdated: ((TappableView, PlatformDropInfo) -> PlatformDropOperation)?

    /// Called when a drag exits the view.
    public var onDragExited: ((TappableView, PlatformDropInfo) -> Void)?

    /// Called to perform the drop operation.
    public var onPerformDrop: ((TappableView, PlatformDropInfo) -> Bool)?

    @available(*, deprecated, message: "Use dropTypes (as String identifiers) instead.")
    public var dropPasteboardTypes: [NSPasteboard.PasteboardType] {
        get { dropTypes.map { NSPasteboard.PasteboardType(rawValue: $0) } }
        set { dropTypes = newValue.map(\.rawValue) }
    }

    /// The configuration object for the TappableView, which defines the behavior of the view when it is tapped or highlighted.
    public var config: TappableViewConfig?

    /// Deprecated: Use `config` instead.
    @available(*, deprecated, renamed: "config")
    public var configuration: TappableViewConfig? {
        get { config }
        set { config = newValue }
    }

    /// A closure that is called when the TappableView is tapped.
    public var onTap: ((TappableView) -> Void)?

    /// A closure that is called when the TappableView is double-tapped.
    public var onDoubleTap: ((TappableView) -> Void)?

    /// A Boolean value that determines whether the TappableView is in a highlighted state.
    /// Changes to this property can trigger an update to the view's appearance.
    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            (config ?? .default).onHighlightChanged?(self, isHighlighted)
        }
    }

    public override var isFlipped: Bool { true }

    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func updateTrackingAreas() {
        if let trackingAreaToken {
            removeTrackingArea(trackingAreaToken)
        }
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInActiveApp, .inVisibleRect, .mouseEnteredAndExited, .enabledDuringMouseDrag],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        trackingAreaToken = trackingArea
        super.updateTrackingAreas()
    }

    private func cancelLongPress(sendCancel: Bool = true) {
        longPressWorkItem?.cancel()
        longPressWorkItem = nil
        if sendCancel, let activeLongPressGesture {
            activeLongPressGesture.state = .cancelled
            onLongPress?(self, activeLongPressGesture)
            self.activeLongPressGesture = nil
        }
    }

    private func scheduleLongPressIfNeeded() {
        guard contextMenuProvider != nil || onLongPress != nil else { return }
        cancelLongPress()

        didTriggerLongPress = false
        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.isHighlighted else { return }

            self.didTriggerLongPress = true
            let gesture = PlatformLongPressGesture(state: .began)
            self.activeLongPressGesture = gesture
            self.onLongPress?(self, gesture)

            if let menu = self.contextMenuProvider?(self) {
                let location = self.pressLocationInView ?? .zero
                menu.popUp(positioning: nil, at: location, in: self)
            }
        }
        longPressWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }

    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isHighlighted = true
        pressLocationInView = convert(event.locationInWindow, from: nil)
        isControlClick = event.modifierFlags.contains(.control) && contextMenuProvider != nil
        scheduleLongPressIfNeeded()
    }

    open override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let location = convert(event.locationInWindow, from: nil)
        isHighlighted = bounds.contains(location)
    }

    open override func mouseUp(with event: NSEvent) {
        defer { isHighlighted = false }
        super.mouseUp(with: event)
        cancelLongPress(sendCancel: false)
        defer { pressLocationInView = nil }
        let location = convert(event.locationInWindow, from: nil)
        guard bounds.contains(location) else { return }

        if didTriggerLongPress, let activeLongPressGesture {
            activeLongPressGesture.state = .ended
            onLongPress?(self, activeLongPressGesture)
            self.activeLongPressGesture = nil
            return
        }
        guard !didTriggerLongPress else { return }

        if isControlClick, let menu = contextMenuProvider?(self) {
            isControlClick = false
            (config ?? .default).didTap?(self)
            menu.popUp(positioning: nil, at: location, in: self)
            return
        }
        isControlClick = false

        (config ?? .default).didTap?(self)
        if event.clickCount == 2 {
            onDoubleTap?(self)
        } else {
            onTap?(self)
        }
    }

    open override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if let cursor = pointerStyleProvider?() {
            cursor.push()
            didPushCursor = true
        }
    }

    open override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHighlighted = false
        cancelLongPress()
        pressLocationInView = nil
        if didPushCursor {
            NSCursor.pop()
            didPushCursor = false
        }
    }

    open override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        isHighlighted = true
    }

    open override func rightMouseUp(with event: NSEvent) {
        defer { isHighlighted = false }
        super.rightMouseUp(with: event)
        guard let menu = contextMenuProvider?(self) else { return }
        let location = convert(event.locationInWindow, from: nil)
        guard bounds.contains(location) else { return }
        (config ?? .default).didTap?(self)
        menu.popUp(positioning: nil, at: location, in: self)
    }

    // MARK: - Drag & Drop

    open override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let onDragEntered {
            return onDragEntered(self, PlatformDropInfo(draggingInfo: sender))
        }
        return dropTypes.isEmpty ? [] : .copy
    }

    open override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let onDragUpdated {
            return onDragUpdated(self, PlatformDropInfo(draggingInfo: sender))
        }
        return dropTypes.isEmpty ? [] : .copy
    }

    open override func draggingExited(_ sender: NSDraggingInfo?) {
        super.draggingExited(sender)
        guard let sender else { return }
        onDragExited?(self, PlatformDropInfo(draggingInfo: sender))
    }

    open override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let onPerformDrop {
            return onPerformDrop(self, PlatformDropInfo(draggingInfo: sender))
        }
        return false
    }
}
#endif
