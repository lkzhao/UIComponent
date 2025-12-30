//  Created by Luke Zhao on 5/12/25.

import SwiftUI

let sizingHostingController = UIHostingController(rootView: AnyView(EmptyView()))

public struct SwiftUIComponent: Component {
    public let content: AnyView
    public let disableSafeArea: Bool

    public init<Content: View>(disableSafeArea: Bool = true, _ content: Content) {
        self.disableSafeArea = disableSafeArea
        self.content = AnyView(content)
    }

    public init<Content: View>(disableSafeArea: Bool = true, @ViewBuilder _ content: () -> Content) {
        self.disableSafeArea = disableSafeArea
        self.content = AnyView(content())
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        sizingHostingController.rootView = content
        let size = sizingHostingController.sizeThatFits(in: constraint.maxSize)
        return ViewComponent<SwiftUIHostingView>().disableSafeArea(disableSafeArea).swiftUIView(content).size(size).layout(constraint)
    }
}

class SwiftUIHostingView: UIView {
    var hostingController: UIHostingController<AnyView>? {
        didSet {
            guard hostingController != oldValue else { return }
            if let oldValue {
                oldValue.willMove(toParent: nil)
                oldValue.view.removeFromSuperview()
                oldValue.removeFromParent()
            }
        }
    }

    var disableSafeArea: Bool = true {
        didSet {
            hostingController?._disableSafeArea = disableSafeArea
        }
    }

    var swiftUIView: AnyView? {
        didSet {
            if let swiftUIView {
                if let hostingController {
                    hostingController.rootView = swiftUIView
                } else {
                    hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController?._disableSafeArea = disableSafeArea
                    if #available(iOS 16.0, *) {
                        hostingController?.sizingOptions = .intrinsicContentSize
                    }
                    hostingController?.view.backgroundColor = .clear
                    addHostingVCToViewIfPossible()
                }
            } else {
                hostingController = nil
            }
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        addHostingVCToViewIfPossible()
    }

    func addHostingVCToViewIfPossible() {
        guard let parentViewController, let hostingController, hostingController.parent != parentViewController else { return }
        hostingController.view.frame = bounds
        hostingController.view.autoresizingMask = []
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(hostingController)
        addSubview(hostingController.view)
        hostingController.didMove(toParent: parentViewController)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostingController?.view.frame = bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        hostingController?.sizeThatFits(in: size) ?? .zero
    }
}

extension UIView {
    //Get Parent View Controller from any view
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)
    }
}
