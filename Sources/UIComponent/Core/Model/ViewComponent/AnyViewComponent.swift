//  Created by y H on 2023/10/30.

import Foundation

public extension ViewComponent {
    func eraseToAnyView() -> AnyViewComponent<R.View> {
        AnyViewComponent(self)
    }
}

public struct AnyViewComponent<View: UIComponentRenderableView>: ViewComponent {
    private let eraseRenderNode: (Constraint) -> AnyViewRenderNode<View>

    init<T: ViewComponent>(_ viewComponent: T) where T.R.View == View {
        if let erased = viewComponent as? AnyViewComponent<View> {
            eraseRenderNode = erased.eraseRenderNode
        } else {
            eraseRenderNode = {
                AnyViewRenderNode(viewComponent.layout($0))
            }
        }
    }

    public func layout(_ constraint: Constraint) -> AnyViewRenderNode<View> {
        eraseRenderNode(constraint)
    }
}

public struct AnyViewRenderNode<View: UIComponentRenderableView>: ViewRenderNode {
    public var size: CGSize { box.size }
    private let box: AnyViewRenderNodeBoxBase<View>

    init<ViewRenderNodeType: ViewRenderNode>(_ viewRenderNode: ViewRenderNodeType) where View == ViewRenderNodeType.View {
        if let erased = viewRenderNode as? AnyViewRenderNode<View> {
            box = erased.box
        } else {
            box = AnyViewRenderNodeBox(viewRenderNode)
        }
    }

    public func updateView(_ view: View) {
        box.updateView(view)
    }

    public func makeView() -> View {
        box.makeView()
    }
}

private class AnyViewRenderNodeBoxBase<ViewType: UIComponentRenderableView>: ViewRenderNode {
    typealias View = ViewType
    var size: CGSize {
        fatalError("Abstract method call", file: #file, line: #line)
    }

    func updateView(_: ViewType) {
        fatalError("Abstract method call", file: #file, line: #line)
    }

    func makeView() -> ViewType {
        fatalError("Abstract method call", file: #file, line: #line)
    }
}

private class AnyViewRenderNodeBox<RenderNodeType: ViewRenderNode>: AnyViewRenderNodeBoxBase<RenderNodeType.View> {
    let base: RenderNodeType
    init(_ base: RenderNodeType) {
        self.base = base
    }

    override var size: CGSize {
        base.size
    }

    override func updateView(_ view: RenderNodeType.View) {
        base.updateView(view)
    }

    override func makeView() -> RenderNodeType.View {
        base.makeView()
    }
}
