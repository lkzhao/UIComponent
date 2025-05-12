# UIComponent Version 5.0 Migration Guide

Version 5.0 introduces several significant changes to improve the API design and performance of UIComponent. This guide will help you migrate your existing code to version 5.0.

## Overview

The main changes in version 5.0 include:
- Simplified flex layout modifiers
- Explicit lazy layout support
- New context value system for RenderNode

## Flex Layout Changes

In version 5.0, the `.flex()` modifier no longer needs to be the outermost modifier. You can now apply other modifiers after `.flex()`, making the API more flexible and intuitive. Additionally, `.flex()` can now be used inside components that conform to the `ComponentBuilder` protocol, which wasn't possible before.

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

## RenderNode Context Value System

Version 5.0 introduces a new context value system for RenderNode. This system provides a unified way to access various properties and behaviors of render nodes, including:
- id
- animator
- reuseStrategy
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

### LazyComponent and Context Values

Note that `LazyComponent` does not support passing context values. If you need to provide context values, you should do it outside of the `LazyComponent`:

```swift
// `id` modifier is not effective since the child is lazily initiated.
MyComponent().id("myId").lazy(width: 50, height: 50)

// Do this instead:
MyComponent()
    .lazy(width: 50, height: 50)
    .id("myId")
```

## Additional Notes

- The context value system provides better type safety and extensibility
- Lazy layout is now more explicit, making it clearer when components are being deferred
- Flex layout is more intuitive with automatic application to direct children
- Consider using the new `.lazy` modifier for performance optimization in lists and complex layouts

For more information about performance optimization with lazy layout, see the [Performance Optimization](PerformanceOptimization.md) guide.
