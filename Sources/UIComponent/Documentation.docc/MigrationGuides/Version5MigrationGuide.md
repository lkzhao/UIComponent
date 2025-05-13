# UIComponent Version 5.0 Changes

Version 5.0 introduces several significant changes to improve the API design of UIComponent. Making it simpler and more predictable. This guide will help you migrate your existing code to version 5.0.

## Overview

The main changes in version 5.0 include:
- [SwiftUI support](#swiftui-support)
- [Simplified flex layout modifiers](#flex-layout-changes)
- [Simplified view reuse system](#view-reuse-changes)
- [CachingItem scope](#cachingitem-scope)
- [Explicit lazy layout](#lazy-layout-changes)
- [New context value system for RenderNode](#rendernode-context-value-system)

## SwiftUI Support

Version 5.0 introduces first-class support for SwiftUI views through the new `SwiftUIComponent`. This allows you to seamlessly integrate SwiftUI views into your UIComponent hierarchy.

### Using SwiftUI Views

You can wrap any SwiftUI view using `SwiftUIComponent`:

```swift
// Create SwiftUIComponent using a SwiftUI View
SwiftUIComponent(Text("Hello World!"))

// You can also create SwiftUIComponent using the ViewBuilder syntax
SwiftUIComponent {
    SwiftUI.Text("Hello World!")
}

// Using a custom SwiftUI view
SwiftUIComponent(MyCustomView())

// Using SwiftUI modifiers
SwiftUIComponent {
    SwiftUI.Text("Hello")
        .font(.title)
        .foregroundColor(.blue)
}

// Using UIComponent modifiers
SwiftUIComponent {
    SwiftUI.Text("Hello")
}.backgroundColor(.black)
```

### Size Control

You can control the size of SwiftUI components using the standard UIComponent size modifiers:

```swift
SwiftUIComponent(MyGradient())
    .size(width: .fill, height: 200)
```

### Integration with UIComponent

SwiftUI Views can be used directly as a component inside UIComponent hierarchy similar to UIViews. It can be mixed with other components.

```swift
// UIComponent VStack
VStack {
    // UIComponent Text
    Text("SwiftUI", font: .boldSystemFont(ofSize: 20))
    
    // SwiftUI Text
    SwiftUI.Text("Hello World!").foregroundColor(.red)
    
    // Regular UIComponent views
    Image("icon")

    // SwiftUI VStack
    SwiftUI.VStack {
        Text("Hello")
        Text("World")
    }

    // To apply a UIComponent modifier, you will have to wrap it inside a SwiftUIComponent
    SwiftUIComponent {
        Text("Hello")
    }.backgroundColor(.black)
}
```

## Flex Layout Changes

In version 5.0, the `.flex()` modifier no longer needs to be the outermost modifier. You can now apply other modifiers after `.flex()`, making the API more flexible and intuitive. Additionally, `.flex()` can now be used inside `ComponentBuilder`, which wasn't possible before, and will fail silently.

```swift
// Before version 5.0
VStack {
    Text("Hello").size(height: 50).flex() // .flex() must be the outermost modifier
    Image("icon").size(width: 100).flex()
}

// After version 5.0
VStack {
    Text("Hello").flex().size(height: 50) // .flex() can be applied before other modifiers
    Image("icon").flex().size(width: 100)
}

// New in version 5.0: .flex() can be used inside ComponentBuilder
struct MyComponent: ComponentBuilder {
    func build() -> some Component {
        Text("Hello").flex()
    }
}

// Before version 5.0, MyComponent's flex won't be effective. You will have to apply the flex outside
VStack {
    MyComponent().flex()
}
```

## View Reuse Changes

In version 5.0, the view reuse system has been simplified and made more explicit. Previously, UIComponent would automatically reuse views based on their types, with the ability to customize behavior using the `.reuseStrategy` modifier. Now, view reuse is controlled entirely through the `.reuseKey` modifier, making the behavior more predictable and deterministic.

> The reason for this change is because modern iOS have optimized the UIView creation cost, and newer iPhones are plenty fast. Reusing cells are not gaining much performance back, but requires careful logic to manage the cell state when the cell is reused, making it easy to introduce settle bugs that are hard to reproduce.

```swift
// Before version 5.0
VStack {
    for item in items {
        ItemComponent(item: item) // Maybe automatically reused based on type
    }
}

// After version 5.0
VStack {
    for item in items {
        ItemComponent(item: item)
            .reuseKey("item-cell") // Explicitly specify reuse key
    }
}
```

### Changes required
- if you previously used `.reuseStrategy(.noReuse)`, you can delete it as it is now the default behavior
- if you previously used `.reuseStrategy(.key("somekey"))`, you need to change it to `.reuseKey("somekey")`
- if you previously used `.reuseStrategy(.automatic)` or if you still wants cell reuse, consider adding a `.reuseKey` modifier with a custom key to maintain the cell reuse functionality.

## CachingItem Scope

Version 5.0 introduces a new `CacheScope` enum to provide more control over the lifetime of cached items. This allows you to specify how long an item should remain in the cache. Previously CachingItem had no `CacheScope` parameter and the `.hostingView` scope was used.

```swift
CachingItem(key: "myItem", scope: .component) { // Explicitly specify cache scope
    // item generation
} componentBuilder: { item in
    // component building
}
```

The available cache scopes are:
- `.component`: The item will be cached until this component is no longer in the hosting view's component tree
- `.hostingView`: The item will be cached until the hosting view is released
- `.global`: The item will be cached until the application is terminated, or until manually cleared using `CachingItem.clearGlobalCache()` or `CachingItem.clearGlobalCacheData(for:)`

### Changes Required
- If you were previously using `CachingItem`, you should review your caching needs and choose the appropriate scope. Previouly the scope is `.hostingView`, now the default is `.component`.
- For items that need to persist even when the component is no long in the component hierarchy, consider using `.hostingView` or `.global` scope.

## Lazy Layout Changes

In version 5.0, fixed-sized items no longer automatically get lazy layout. Instead, you need to explicitly use the new `.lazy` modifier when you want to defer layout and rendering.

```swift
// Before version 5.0
VStack {
    for item in items {
        ItemComponent(item: item).size(width: 50, height: 50) // Automatically lazy
    }
}

// After version 5.0
VStack {
    for item in items {
        ItemComponent(item: item)
            .lazy(width: 50, height: 50) // Explicitly mark as lazy
    }
}
```

You can also provide a custom size provider for dynamic sizing based on the constraint:

```swift
VStack {
    for item in items {
        ItemComponent(item: item)
            .lazy { constraint in
                CGSize(width: constraint.maxWidth, height: 50 + item.isTall ? 50 : 0)
            }
    }
}
```

### LazyComponent and Context Values

Note that `LazyComponent` does not support passing context values (id, animator, reuseKey, flex, etc...). If you need to provide context values, you should do it outside of the `LazyComponent`:

```swift
// `id` modifier is not effective since the child is lazily initiated.
MyComponent().id("myId").lazy(width: 50, height: 50)

// Do this instead:
MyComponent()
    .lazy(width: 50, height: 50)
    .id("myId")
```

## RenderNode Context Value System

Version 5.0 introduces a new context value system for RenderNode. This system provides a unified way to access various properties and behaviors of render nodes, including:
- id
- animator
- reuseKey
- flexGrow
- flexShrink
- alignSelf
- and more

### Accessing Context Values

Instead of accessing properties directly, you now use the `contextValue(_:)` method:

```swift
// Before version 5.0
let id = renderNode.id
let animator = renderNode.animator

// After version 5.0
let id = renderNode.contextValue(.id) as? String
let animator = renderNode.contextValue(.animator) as? Animator
```

### Custom Context Values

You can define your own context values by creating a new `RenderNodeContextKey`:

```swift
extension RenderNodeContextKey {
    static let myCustomKey = RenderNodeContextKey("myCustomKey")
}

// Using the custom context value
let value = renderNode.contextValue(.myCustomKey) as? MyType
```

### Changes Required
- If you have implemented custom RenderNode, and overriden `id`, `animator`, You will need to now provide it inside the `contextValue(_:)` method.