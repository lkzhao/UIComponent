# Performance Optimization

Tips and tricks for improving the performance of your app.

## Overview

UIComponent provides great performance out of the box, especially when rendering a list. However, there are still some things you can do to improve the performance of your app when rendering large amount of views. 
> These optimization tips are advance topics. You should only consider these when you have a performance problem.

### Layout
One of the biggest performance bottlenecks is layout. If you have a complex layout, it can take a long time to calculate before the Component renders. Here are some tips to improve the layout performance.

#### Use Lazy Layout for Deferred Rendering

In version 5.0, UIComponent introduces explicit lazy layout support through the `.lazy` modifier. This allows you to defer the layout and rendering of components until they are actually needed, which can significantly improve performance for complex layouts.

To use lazy layout, you need to:
1. Know the size of your component in advance
2. Apply the `.lazy` modifier with the appropriate size

Here's how to use it:

```swift
VStack {
    for item in items {
        VStack {
            Image(item.image)
            Text(item.title)
            Text(item.subtitle)
        }.lazy(width: .fill, height: 50) // Defer layout until needed
    }
}
```

You can also provide a custom size provider if the size needs to be calculated dynamically:

```swift
VStack {
    for item in items {
        VStack {
            // Some content
        }.lazy(sizeProvider: { constraint in
            CGSize(width: constraint.maxWidth, height: 50 + item.isTall ? 50 : 0)
        })
    }
}
```

> Note: The `.lazy` modifier is particularly useful for components with complex layouts that are not immediately visible on screen. It defers both the layout calculation and view creation until the component is about to become visible.

> Tip: One other way to optimize a complex layout for each cell is to write a size cache. So each cell's size is only calculated once. Therefore making reload much faster.
**Specific implementation is not provided.**


#### Use Custom View to render cells instead of Component.

You can also create a custom view that wraps your child component. This way the child component won't be constructed or layed out when reloading the list.

```swift
class ItemView: PlatformView {
    var item: Item? {
        didSet {
            guard item != oldValue else { return }
            componentEngine.component = VStack {
                Image(item.image)
                Text(item.title)
                Text(item.subtitle)
            }
        }
    }
}
VStack {
    for item in items {
        ViewComponent<ItemView>().item(item).size(width: .fill, height: 50)
    }
}
```

#### Async layout (Beta)

UIComponent also provides an ``ComponentEngine/asyncLayout`` option. 
This allows the ``ComponentEngine`` to run layout calculation on a background thread and free up the main UI thread. It should improve the framerate and scroll performance, but it does not improve the layout latency. (i.e. if you layout takes 2 seconds, it will still take 2 seconds to complete, but the user are able to scroll and interact with the app while the calculation is running)

To enabled async layout on a ``ComponentEngine``:
```swift
view.componentEngine.asyncLayout = true
```

Keep in mind that doing layout on a background thread have a few implications, you should only consider this approach on a performance critical situation:
1. View hierarchy will not immediately reflect the Component state even if after calling ``ComponentEngine/reloadData(contentOffsetAdjustFn:)``
2. Your layout code inside your components must be thread safe.
    * Fortunately, most components are structs which are thread safe by default.
3. Your layout code must not access UI properties during layout.
