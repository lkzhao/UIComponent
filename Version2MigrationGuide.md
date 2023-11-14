# UIComponent Version 2.0 Migration Guide

With version 2.0, UIComponent doesn't distinquish between V1's `ViewComponent` and `Component` anymore.
All Component can now render a view.

For example, before 2.0, you have to do the following to render a rectangle
```swift
// version 1.x
Space(width: 300, height: 300).view().backgroundColor(.red)

// version 2.0
Space(width: 300, height: 300).backgroundColor(.red)
```

The `.view()` modifier was required because `Space` isn't a `ViewComponent` so it doesn't render a UIView onto the screen. Version 2.0 relaxes this requirement and allows any component to render a view onto the screen. The component's renderNode can return `true` for `shouldRenderView` to let the system know that it wants to render a view onto the screen. And corresponding `makeView` and `updateView` will be called if so.

Modifiers can also wrap exising components and force components to render a view. In the above example, `Space` component doesn't usually render a view. But because `.backgroundColor` modifier is applied, it now becomes a `ViewUpdateComponent` which forces it to render a view.


### Migration Steps:
* Rename:
    * `ViewComponent` -> `Component`
    * `ViewComponentBuilder` -> `ComponentBuilder`
    * `ViewModifierComponent` -> `ModifierComponent`
    * `ViewUpdateComponent` -> `UpdateComponent`
    * `ViewKeyPathUpdateComponent` -> `KeyPathUpdateComponent`
    * `ViewIDComponent` -> `IDComponent`
    * `ViewAnimatorComponent` -> `AnimatorComponent`
    * `ViewAnimatorWrapperComponent` -> `AnimatorWrapperComponent`
    * `ViewReuseStrategyComponent` -> `ReuseStrategyComponent`
* Check if `.view()` is still necessary.
    * In some instances where you only want to render a view, without wrapping a component into a ComponentView. `.view()` is not necessary anymore.
* When storing `Component` as a property, it needs to be written as `any Component` or specific type of `Component`

* When returning `Component` or `RenderNode` it needs to be `some Component` and `some RenderNode` or specific type of `Component` or `RenderNode` If the type is associated to the protocol. Or `any Component` and `any RenderNode` if the type isn't associated.

* Sometimes, when the return type doesn't match the requirement of `some Component` or `some RenderNode` due to multiple types being returned. You can use `.eraseToAnyComponent()` or `eraseToAnyRenderNode()` to bypass the requirement by wrapping it into `AnyComponent` or `AnyRenderNode`
