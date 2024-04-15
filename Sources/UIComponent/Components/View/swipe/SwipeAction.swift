//  Created by y H on 2024/4/7.

import UIKit

public typealias SwipeActionHandler = (_ action: any SwipeAction) -> Void

public enum SwipeHorizontalEdge {
    case left, right
    var isLeft: Bool { self == .left }
}

public enum SwipeActionStyle {
    case `default`
    case destructive
}

public enum SwipeActionEventFrom {
    case tap
    case expanded
    case alert
}

public enum SwipeActionAfterHandler {
    case close
    case swipeFull(_ completion: (() -> Void)? = nil)
    case alert
}

public protocol SwipeAction {
    typealias CompletionAfterHandler = (SwipeActionAfterHandler) -> Void
    associatedtype View: UIView
    var identifier: String { get }
    var horizontalEdge: SwipeHorizontalEdge { get }
    var view: View { get }
    func makeExpandedView() -> UIView?
    func makeAlertView() -> UIView
    func isSame(_ other: any SwipeAction) -> Bool
    func handlerAction(completion: @escaping CompletionAfterHandler, eventFrom: SwipeActionEventFrom)
    func willShow()
}

public extension SwipeAction {
    func isSame(_ other: any SwipeAction) -> Bool {
        identifier == other.identifier && horizontalEdge == other.horizontalEdge
    }

    func makeExpandedView() -> UIView? {
        return nil
    }
    
    func makeAlertView() -> UIView {
        fatalError()
    }
    
    func willShow() {}
}

public extension SwipeAction {
    static func == (lhs: any SwipeAction, rhs: any SwipeAction) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

public struct SwipeActionComponent: SwipeAction {
    public typealias ActionHandler = (_ completion: @escaping CompletionAfterHandler, _ action: any SwipeAction, _ form: SwipeActionEventFrom) -> Void
    public typealias ComponentProvider = () -> any Component
    public let identifier: String
    public let horizontalEdge: SwipeHorizontalEdge
    public let view: ComponentView
    public let alert: (any Component)?
    public let background: any Component
    public let component: any Component
    public let actionHandler: SwipeActionComponent.ActionHandler

    public init(identifier: String = UUID().uuidString, horizontalEdge: SwipeHorizontalEdge, backgroundColor: UIColor, body: SwipeActionComponent.ComponentProvider, alert: SwipeActionComponent.ComponentProvider? = nil, actionHandler: @escaping SwipeActionComponent.ActionHandler) {
        self.init(identifier: identifier,
                  horizontalEdge: horizontalEdge,
                  component: body,
                  background: { Space().backgroundColor(backgroundColor) },
                  alert: alert,
                  actionHandler: actionHandler)
    }

    init(identifier: String, horizontalEdge: SwipeHorizontalEdge, component: SwipeActionComponent.ComponentProvider, background: SwipeActionComponent.ComponentProvider? = nil, alert: ComponentProvider? = nil, actionHandler: @escaping SwipeActionComponent.ActionHandler) {
        self.identifier = identifier
        self.horizontalEdge = horizontalEdge
        let component = component()
        let background = background?() ?? Space()
        self.alert = alert?()
        self.background = background
        self.component = component
        self.actionHandler = actionHandler
        self.view = ComponentView()
        self.view.component = wrapLayout(body: component, justifyContent: horizontalEdge.isLeft ? .end : .start)
    }

    public func makeExpandedView() -> UIView? {
        let componentView = ComponentView()
        componentView.component = wrapLayout(body: component, justifyContent: horizontalEdge == .left ? .end : .start)
        return componentView
    }
    
    public func makeAlertView() -> UIView {
        guard let alert else { fatalError("Implement alert closure") }
        let componentView = ComponentView()
        componentView.component = wrapLayout(body: alert, justifyContent: .center)
        return componentView
    }
    
    public func handlerAction(completion: @escaping CompletionAfterHandler, eventFrom: SwipeActionEventFrom) {
        actionHandler(completion, self, eventFrom)
    }

    func wrapLayout(body: any Component, justifyContent: MainAxisAlignment) -> WrapLayout {
        WrapLayout(justifyContent: justifyContent, background: background) { body }
    }
    
    struct WrapLayout: ComponentBuilder {
        let justifyContent: MainAxisAlignment
        let components: [any Component]
        let background: any Component
        init(justifyContent: MainAxisAlignment, background: any Component, @ComponentArrayBuilder _ components: () -> [any Component]) {
            self.justifyContent = justifyContent
            self.components = components()
            self.background = background
        }

        func build() -> some Component {
            HStack(justifyContent: justifyContent, alignItems: .center) {
                components
            }
            .fill()
            .background {
                background
            }
        }
    }
}

@resultBuilder
public enum SwipeActionBuilder {
    public static func buildExpression(_ expression: any SwipeAction) -> [any SwipeAction] {
        [expression]
    }

    public static func buildExpression(_ expression: (any SwipeAction)?) -> [any SwipeAction] {
        [expression].compactMap { $0 }
    }

    public static func buildExpression(_ expression: [any SwipeAction]) -> [any SwipeAction] {
        expression
    }

    public static func buildBlock(_ segments: [any SwipeAction]...) -> [any SwipeAction] {
        segments.flatMap { $0 }
    }

    public static func buildIf(_ segments: [any SwipeAction]?...) -> [any SwipeAction] {
        segments.flatMap { $0 ?? [] }
    }

    public static func buildEither(first: [any SwipeAction]) -> [any SwipeAction] {
        first
    }

    public static func buildEither(second: [any SwipeAction]) -> [any SwipeAction] {
        second
    }

    public static func buildArray(_ components: [[any SwipeAction]]) -> [any SwipeAction] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any SwipeAction]) -> [any SwipeAction] {
        component
    }
}