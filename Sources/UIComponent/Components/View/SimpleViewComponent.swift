//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct SimpleViewComponent<View: UIView>: ViewComponent {
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
    public func layout(_ constraint: Constraint) -> SimpleViewRenderNode<View> {
        SimpleViewRenderNode(size: (view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint), view: view, generator: generator)
    }
}

public struct SimpleViewRenderNode<View: UIView>: ViewRenderNode {
    public let size: CGSize
    public let view: View?
    public let generator: (() -> View)?
    public var id: String? {
        if let view = view {
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
        if let view = view {
            return view
        } else if let generator = generator {
            return generator()
        } else {
            return View()
        }
    }

    public func updateView(_ view: View) {}
}

@available(iOS 13.0, *)
extension UIView: ViewComponent {
    public func layout(_ constraint: Constraint) -> some ViewRenderNode {
        SimpleViewRenderNode(size: constraint.isTight ? constraint.maxSize : sizeThatFits(constraint.maxSize).bound(to: constraint), view: self)
    }
}
