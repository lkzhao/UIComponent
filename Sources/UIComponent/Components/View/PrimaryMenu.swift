//
//  File.swift
//  
//
//  Created by Luke Zhao on 11/26/22.
//

import UIKit

#if !os(tvOS)
/// `PrimaryMenuConfig` defines the configuration for a `PrimaryMenu`.
/// It provides customization options such as highlight state changes and tap actions.
@available(iOS 14.0, *)
public struct PrimaryMenuConfig {
    /// The default configuration for all PrimaryMenu instances.
    public static var `default`: PrimaryMenuConfig = PrimaryMenuConfig(onHighlightChanged: nil, didTap: nil)

    /// Closure to apply highlight state or animation to the TappableView.
    public var onHighlightChanged: ((PrimaryMenu, Bool) -> Void)?

    /// Closure to be called before the actual onTap action is performed.
    public var didTap: ((PrimaryMenu) -> Void)?

    /// Initializes a new configuration for the `PrimaryMenu`.
    /// - Parameters:
    ///   - onHighlightChanged: A closure that gets called when the highlight state changes.
    ///   - didTap: A closure that gets called when the `PrimaryMenu` is tapped.
    public init(onHighlightChanged: ((PrimaryMenu, Bool) -> Void)? = nil, didTap: ((PrimaryMenu) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

@available(*, deprecated, renamed: "PrimaryMenuConfig")
@available(iOS 14.0, *)
public typealias PrimaryMenuConfiguration = PrimaryMenuConfig

/// A UIControl subclass that displays a context menu when tapped.
@available(iOS 14.0, *)
public class PrimaryMenu: UIControl {
    /// Indicates whether any `PrimaryMenu` is currently showing a menu.
    public static fileprivate(set) var isShowingMenu = false

    /// The configuration object that defines behavior for the `PrimaryMenu`.
    public var config: PrimaryMenuConfig?

    /// Deprecated: Use `config` instead.
    @available(*, deprecated, renamed: "config")
    public var configuration: PrimaryMenuConfig? {
        get { config }
        set { config = newValue }
    }

    /// A flag indicating whether the menu is currently being displayed.
    public var isShowingMenu = false

    /// The menu to be displayed when the control is interacted with.
    public var menuBuilder: (() -> UIMenu)? {
        didSet {
            guard isShowingMenu else { return }
            if let menuBuilder {
                contextMenuInteraction?.updateVisibleMenu({ _ in
                    return menuBuilder()
                })
            } else {
                contextMenuInteraction?.dismissMenu()
            }
        }
    }

    /// A private storage for the preferred order of menu elements.
    private var _preferredMenuElementOrder: Any?

    /// The preferred order of elements within the context menu.
    @available(iOS 16.0, *)
    public var preferredMenuElementOrder: UIContextMenuConfiguration.ElementOrder {
        get { _preferredMenuElementOrder as? UIContextMenuConfiguration.ElementOrder ?? .automatic }
        set { _preferredMenuElementOrder = newValue }
    }

    /// A type-erased pointer style provider.
    private var _pointerStyleProvider: Any?

    /// A closure that provides a pointer style when the control is hovered over with a pointer device.
    public var pointerStyleProvider: (() -> UIPointerStyle?)? {
        get { _pointerStyleProvider as? () -> UIPointerStyle? }
        set { _pointerStyleProvider = newValue }
    }

    /// A flag indicating whether the control is currently in a pressed state.
    public private(set) var isPressed: Bool = false {
        didSet {
            guard isPressed != oldValue else { return }
            (config ?? .default).onHighlightChanged?(self, isPressed)
        }
    }

    /// Initializes a new instance of the `PrimaryMenu`.
    /// - Parameter frame: The frame rectangle for the control, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsMenuAsPrimaryAction = true
        isContextMenuInteractionEnabled = true
        accessibilityTraits = .button
        addInteraction(UIPointerInteraction(delegate: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch Handling

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPressed = true
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isPressed = false
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isPressed = false
    }

    // MARK: - UIContextMenuInteractionDelegate

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        (config ?? .default).didTap?(self)
        let menuConfiguration = UIContextMenuConfiguration(actionProvider: { [menuBuilder] suggested in
            return menuBuilder?()
        })
        if #available(iOS 16.0, *) {
            menuConfiguration.preferredMenuElementOrder = self.preferredMenuElementOrder
        }
        return menuConfiguration
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        isShowingMenu = true
        PrimaryMenu.isShowingMenu = true
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        isShowingMenu = false
        PrimaryMenu.isShowingMenu = false
    }
}

// MARK: - UIPointerInteractionDelegate

@available(iOS 14.0, *)
extension PrimaryMenu: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        if let pointerStyleProvider {
            return pointerStyleProvider()
        } else {
            return UIPointerStyle(effect: .automatic(UITargetedPreview(view: self)), shape: nil)
        }
    }
}
#endif
