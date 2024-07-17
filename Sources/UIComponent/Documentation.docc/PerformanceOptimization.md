# Performance Optimization

Tips and tricks for improving the performance of your app.

## Overview

UIComponent provides great performance out of the box, especially when rendering a list. However, there are still some things you can do to improve the performance of your app when rendering large amount of views. 
> These optimization tips are advance topics. You should only consider these when you have a performance problem.

### Layout
One of the biggest performance bottlenecks is layout. If you have a complex layout, it can take a long time to calculate before the Component renders. Here are some tips to improve the layout performance.

#### Use fixed size whenever possible

When rendering large amount of cells, try to assign a fixed size to each cell. This way UIComponent doesn't need to run layout calculation for each cell while laying out the entire list.

The following example is slow because UIComponent will need to run layout for all of the child components in order to get a size for each before it can display any cell.
```swift
VStack {
    for item in items {
        VStack {
            Image(item.image)
            Text(item.title)
            Text(item.subtitle)
        }
    }
}
```

A more performant way is to assign a fixed size to each child. This allows UIComponent to skip layout of the content until the content is scrolled on screen.

```swift
VStack {
    for item in items {
        VStack {
            Image(item.image)
            Text(item.title)
            Text(item.subtitle)
        }.size(width: .fill, height: 50) // fixed height. 
    }
}
```

> Except for the ``SizeStrategy/fit``, all other size strategy including ``SizeStrategy/fill``, ``SizeStrategy/absolute(_:)``, ``SizeStrategy/percentage(_:)``, ``SizeStrategy/aspectPercentage(_:)`` all supports this lazy layout optimization.

#### Manually calculate the size
You can also provide a simple size block to calculate the size of each cell instead of relying on UIComponent to calculate for you. Keep in mind that the calculation should be kept simple, otherwise there is no benefit on doing manual size calculation.

```swift
VStack {
    for item in items {
        VStack {
            // Some complex content
        }.size { constraint in
            CGSize(width: constraint.maxWidth, height: 50 + item.isTall ? 50 : 0)
        }
    }
}
```

> Tip: One other way to optimize a complex layout for each cell is to write a size cache. So each cell's size is only calculated once. Therefore making reload much faster.
**Specific implementation is not provided.**


#### Use Custom View to render cells instead of Component.

You can also create a custom view that wraps your child component. This way the child component won't be constructed or layed out when reloading the list.

```swift
class ItemView: ComponentView {
    var item: Item? {
        didSet {
            guard item != oldValue else { return }
            component = VStack {
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
This allows the ``ComponentView`` to run layout calculation on a background thread and free up the main UI thread. It should improve the framerate and scroll performance, but it does not improve the layout latency. (i.e. if you layout takes 2 seconds, it will still take 2 seconds to complete, but the user are able to scroll and interact with the app while the calculation is running)

To enabled async layout on a ``ComponentView``:
```swift
componentView.componentEngine.asyncLayout = true
```

Keep in mind that doing layout on a background thread have a few implications, you should only consider this approach on a performance critical situation:
1. View hierarchy will not immediately reflect the Component state even if after calling ``ComponentView/reloadData(contentOffsetAdjustFn:)``
2. Your layout code inside your components must be thread safe.
    * Fortunately, most components are structs which are thread safe by default.
3. Your layout code must not access UI properties during layout.
