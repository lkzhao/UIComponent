//  Created by Luke Zhao on 8/19/21.

import UIKit

public struct ViewModifierComponent<Content: ViewComponent, Result: RenderNode>: ViewComponent where Content.R.View == Result.View {
    let content: Content
    let modifier: (Content.R) -> Result

    public func layout(_ constraint: Constraint) -> Result {
        modifier(content.layout(constraint))
    }
}

public typealias ViewUpdateComponent<Content: ViewComponent> = ViewModifierComponent<Content, UpdateRenderNode<Content.R>>

public typealias ViewKeyPathUpdateComponent<Content: ViewComponent, Value> = ViewModifierComponent<
    Content, KeyPathUpdateRenderNode<Value, Content.R>
>

public typealias ViewIDComponent<Content: ViewComponent> = ViewModifierComponent<Content, IDRenderNode<Content.R>>

public typealias ViewAnimatorComponent<Content: ViewComponent> = ViewModifierComponent<Content, AnimatorRenderNode<Content.R>>

public typealias ViewAnimatorWrapperComponent<Content: ViewComponent> = ViewModifierComponent<Content, AnimatorWrapperRenderNode<Content.R>>

public typealias ViewReuseStrategyComponent<Content: ViewComponent> = ViewModifierComponent<Content, ReuseStrategyRenderNode<Content.R>>

extension ViewComponent {
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> ViewKeyPathUpdateComponent<Self, Value> {
        { with(keyPath, $0) }
    }

    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewKeyPathUpdateComponent<Self, Value> {
        ViewModifierComponent(content: self) {
            $0.with(keyPath, value)
        }
    }

    public func id(_ id: String?) -> ViewIDComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.id(id)
        }
    }

    public func animator(_ animator: Animator?) -> ViewAnimatorComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.animator(animator)
        }
    }

    public func reuseStrategy(_ reuseStrategy: ReuseStrategy) -> ViewReuseStrategyComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.reuseStrategy(reuseStrategy)
        }
    }

    public func update(_ update: @escaping (R.View) -> Void) -> ViewUpdateComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.update(update)
        }
    }
}

extension ViewComponent {
    public func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> ViewAnimatorWrapperComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.animateUpdate(passthrough: passthrough, updateBlock)
        }
    }
}

extension ViewComponent {
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }
    public func size(width: CGFloat, height: SizeStrategy = .fit) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
    }
    public func size(width: CGFloat, height: CGFloat) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
    }
    public func size(_ size: CGSize) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }
    public func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
    }
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }
    public func constraint(_ constraint: Constraint) -> ConstraintOverrideViewComponent<Self> {
        ConstraintOverrideViewComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
    }
    public func unboundedWidth() -> ConstraintOverrideViewComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }
    public func unboundedHeight() -> ConstraintOverrideViewComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }
}

extension ViewComponent where R.View: UIView {
    public func roundedCorner() -> ViewUpdateComponent<Self> {
        ViewModifierComponent(content: self) { node in
            node.update { view in
                view.cornerRadius = min(node.size.width, node.size.height) / 2
            }
        }
    }
}
