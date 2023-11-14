//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct ViewComponent<View: UIView>: Component {
    public let view: View?
    public let generator: (() -> View)?
    private init(view: View?, generator: (() -> View)?) {
        self.view = view
        self.generator = generator
    }
    public init(view: View? = nil) {
        self.init(view: view, generator: nil)
    }
    public init(generator: @autoclosure @escaping () -> View) {
        self.init(view: nil, generator: generator)
    }
    public func layout(_ constraint: Constraint) -> ViewRenderNode<View> {
        ViewRenderNode(size: (view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint), view: view, generator: generator)
    }
}

public struct ViewRenderNode<View: UIView>: RenderNode {
    public let size: CGSize
    public let view: View?
    public let generator: (() -> View)?
    public var id: String? {
        if let view {
            return "view-at-\(Unmanaged.passUnretained(view).toOpaque())"
        }
        return nil
    }
    public var reuseStrategy: ReuseStrategy {
        view == nil ? .automatic : .noReuse
    }

    fileprivate init(size: CGSize, view: View?, generator: (() -> View)?) {
        self.size = size
        self.view = view
        self.generator = generator
    }

    public init(size: CGSize) {
        self.init(size: size, view: nil, generator: nil)
    }

    public init(size: CGSize, view: View) {
        self.init(size: size, view: view, generator: nil)
    }

    public init(size: CGSize, generator: @escaping (() -> View)) {
        self.init(size: size, view: nil, generator: generator)
    }

    public func makeView() -> View {
        if let view {
            return view
        } else if let generator {
            return generator()
        } else {
            return View()
        }
    }

    public func updateView(_ view: View) {}
}

extension UIView: Component {
    public func layout(_ constraint: Constraint) -> ViewRenderNode<UIView> {
        ViewRenderNode(size: constraint.isTight ? constraint.maxSize : sizeThatFits(constraint.maxSize).bound(to: constraint), view: self)
    }
}
