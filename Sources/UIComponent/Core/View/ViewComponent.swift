//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import Foundation

@dynamicMemberLookup
public protocol ViewComponent: Component {
    associatedtype R: ViewRenderer
    func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
    public func layout(_ constraint: Constraint) -> Renderer {
        layout(constraint) as R
    }
}

public struct ViewModifierComponent<View, Content: ViewComponent, Result: ViewRenderer>: ViewComponent where Content.R.View == View, Result.View == View {
    let content: Content
    let modifier: (Content.R) -> Result
    
    public func layout(_ constraint: Constraint) -> Result {
        modifier(content.layout(constraint))
    }
}

public typealias ViewUpdateComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewUpdateRenderer<Content.R.View, Content.R>>

public typealias ViewKeyPathUpdateComponent<Content: ViewComponent, Value> = ViewModifierComponent<Content.R.View, Content, ViewKeyPathUpdateRenderer<Content.R.View, Value, Content.R>>

public typealias ViewIDComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewIDRenderer<Content.R.View, Content.R>>

public typealias ViewAnimatorComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewAnimatorRenderer<Content.R.View, Content.R>>

public typealias ViewReuseKeyComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewReuseKeyRenderer<Content.R.View, Content.R>>

public extension ViewComponent {
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<R.View, Value>) -> (Value) -> ViewKeyPathUpdateComponent<Self, Value> {
        { with(keyPath, $0) }
    }
    
    func with<Value>(_ keyPath: ReferenceWritableKeyPath<R.View, Value>, _ value: Value) -> ViewKeyPathUpdateComponent<Self, Value> {
        ViewModifierComponent(content: self) {
            $0.with(keyPath, value)
        }
    }
    
    func id(_ id: String) -> ViewIDComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.id(id)
        }
    }
    
    func animator(_ animator: Animator?) -> ViewAnimatorComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.animator(animator)
        }
    }
    
    func reuseKey(_ reuseKey: String?) -> ViewReuseKeyComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.reuseKey(reuseKey)
        }
    }
    
    func update(_ update: @escaping (R.View) -> Void) -> ViewUpdateComponent<Self> {
        ViewModifierComponent(content: self) {
            $0.update(update)
        }
    }
}
