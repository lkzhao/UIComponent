//
//  File.swift
//  
//
//  Created by Luke Zhao on 11/26/22.
//

import UIKit

@available(iOS 14.0, *)
public struct PrimaryMenuComponent: ViewComponent {
    let component: Component
    let menu: UIMenu

    public init(component: Component, menu: UIMenu) {
        self.component = component
        self.menu = menu
    }

    public func layout(_ constraint: Constraint) -> ViewUpdateRenderNode<SimpleViewRenderNode<PrimaryMenu>> {
        let renderNode = component.layout(Constraint(maxSize: constraint.maxSize))
        return SimpleViewComponent<PrimaryMenu>().size(renderNode.size).update {
            $0.menu = menu
            $0.contentView.engine.reloadWithExisting(component: component, renderNode: renderNode)
        }.layout(constraint)
    }
}

@available(iOS 14.0, *)
public extension Component {
    func primaryMenu(_ menuBuilder: () -> UIMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menu: menuBuilder())
    }
    func primaryMenu(_ menu: UIMenu) -> PrimaryMenuComponent {
        PrimaryMenuComponent(component: self, menu: menu)
    }
}

@available(iOS 14.0, *)
public struct PrimaryMenuConfiguration {
    public static var `default` = PrimaryMenuConfiguration(onHighlightChanged: nil, didTap: nil)

    // place to apply highlight state or animation to the PrimaryMenu
    public var onHighlightChanged: ((PrimaryMenu, Bool) -> Void)?

    // hook before the actual onTap is called
    public var didTap: ((PrimaryMenu) -> Void)?

    public init(onHighlightChanged: ((PrimaryMenu, Bool) -> Void)? = nil, didTap: ((PrimaryMenu) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

@available(iOS 14.0, *)
public class PrimaryMenu: UIControl {
    public static fileprivate(set) var isShowingMenu = false

    public var configuration: PrimaryMenuConfiguration?

    let contentView = ComponentView()

    public var isShowingMenu = false
    public var menu: UIMenu? {
        didSet {
            guard isShowingMenu else { return }
            if let menu {
                contextMenuInteraction?.updateVisibleMenu({ _ in
                    return menu
                })
            } else {
                contextMenuInteraction?.dismissMenu()
            }
        }
    }

    private var _preferredMenuElementOrder: Any?
    @available(iOS 16.0, *)
    var preferredMenuElementOrder: UIContextMenuConfiguration.ElementOrder {
        get { _preferredMenuElementOrder as? UIContextMenuConfiguration.ElementOrder ?? .automatic }
        set { _preferredMenuElementOrder = newValue }
    }

    public var component: Component? {
        get { contentView.component }
        set { contentView.component = newValue }
    }

    public private(set) var isPressed: Bool = false {
        didSet {
            guard isPressed != oldValue else { return }
            let config = configuration ?? PrimaryMenuConfiguration.default
            config.onHighlightChanged?(self, isPressed)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        showsMenuAsPrimaryAction = true
        isContextMenuInteractionEnabled = true
        addSubview(contentView)
        accessibilityTraits = .button
        contentView.addInteraction(UIPointerInteraction(delegate: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.sizeThatFits(size)
    }

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

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let config = configuration ?? PrimaryMenuConfiguration.default
        config.didTap?(self)
        return UIContextMenuConfiguration(actionProvider: { [menu] suggested in
            return menu
        }).then {
            if #available(iOS 16.0, *) {
                $0.preferredMenuElementOrder = self.preferredMenuElementOrder
            }
        }
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

@available(iOS 14.0, *)
extension PrimaryMenu: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, regionFor request: UIPointerRegionRequest, defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        defaultRegion
    }
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return UIPointerStyle(effect: .automatic(UITargetedPreview(view: contentView)), shape: nil)
    }
}
