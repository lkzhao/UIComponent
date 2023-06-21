//  Created by Luke Zhao on 8/19/21.

import UIKit

public struct ModifierComponent<Content: Component, Result: RenderNode>: Component where Content.R.View == Result.View {
    let content: Content
    let modifier: (Content.R) -> Result

    public func layout(_ constraint: Constraint) -> Result {
        modifier(content.layout(constraint))
    }
}

public typealias UpdateComponent<Content: Component> = ModifierComponent<Content, UpdateRenderNode<Content.R>>

public typealias KeyPathUpdateComponent<Content: Component, Value> = ModifierComponent<
    Content, KeyPathUpdateRenderNode<Value, Content.R>
>

public typealias IDComponent<Content: Component> = ModifierComponent<Content, IDRenderNode<Content.R>>

public typealias AnimatorComponent<Content: Component> = ModifierComponent<Content, AnimatorRenderNode<Content.R>>

public typealias AnimatorWrapperComponent<Content: Component> = ModifierComponent<Content, AnimatorWrapperRenderNode<Content.R>>

public typealias ReuseStrategyComponent<Content: Component> = ModifierComponent<Content, ReuseStrategyRenderNode<Content.R>>

extension Component {
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> KeyPathUpdateComponent<Self, Value> {
        { value in
            with(keyPath, value)
        }
    }

    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> KeyPathUpdateComponent<Self, Value> {
        ModifierComponent(content: self) {
            $0.with(keyPath, value)
        }
    }

    public func id(_ id: String?) -> IDComponent<Self> {
        ModifierComponent(content: self) {
            $0.id(id)
        }
    }

    public func animator(_ animator: Animator?) -> AnimatorComponent<Self> {
        ModifierComponent(content: self) {
            $0.animator(animator)
        }
    }

    public func reuseStrategy(_ reuseStrategy: ReuseStrategy) -> ReuseStrategyComponent<Self> {
        ModifierComponent(content: self) {
            $0.reuseStrategy(reuseStrategy)
        }
    }

    public func update(_ update: @escaping (R.View) -> Void) -> UpdateComponent<Self> {
        ModifierComponent(content: self) {
            $0.update(update)
        }
    }
}

extension Component {
    public func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateUpdate(passthrough: passthrough, updateBlock)
        }
    }
}

extension Component {
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }
    public func size(width: CGFloat, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
    }
    public func size(width: CGFloat, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
    }
    public func size(_ size: CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }
    public func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
    }
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }
    public func constraint(_ constraint: Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(child: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
    }
    public func unboundedWidth() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }
    public func unboundedHeight() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }
}

extension Component {
    public func roundedCorner() -> UpdateComponent<Self> {
        ModifierComponent(content: self) { node in
            node.update { view in
                view.cornerRadius = min(node.size.width, node.size.height) / 2
            }
        }
    }
}
