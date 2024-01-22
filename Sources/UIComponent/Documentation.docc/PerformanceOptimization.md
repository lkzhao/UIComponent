# Performance Optimization

Tips and tricks for improving the performance of your app.

## Overview

UIComponent provides great performance out of the box, especially when rendering a list. However, there are still some things you can do to improve the performance of your app when rendering large amount of views. 
> These optimization tips are advance topics. You should only consider these when you have a performance problem.

### Layout
One of the biggest performance bottlenecks is layout. If you have a complex layout, it can take a long time to calculate before the Component renders. Here are some tips to improve the layout performance.

#### Use Custom View to render cells instead of Component.
When rendering large amount of cells, it might be better to a custom view with a fixed size to render each cell instead of using Component to built your cell in place. This way UIComponent doesn't need to run layout for each cell while laying out the entire list. This saves a lot of processing because the layout inside the cell are not being calculated until the cell is rendered on screen.
```swift
VStack {
    for item in items {
        VStack {
            // UIComponent will need to run layout for all of the children here 
            // to get a size for each before it can display any cell.
            Image(item.image)
            Text(item.title)
            Text(item.subtitle)
        }
    }
}
```

A more performant way is to create a Custom view that renders the cell's component.

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
        // Much faster layout here because it doesn't need to run layout for the cells's content
        ViewComponent<ItemView>().item(item).size(width: .fill, height: 50)
    }
}
```

#### Caching size of the cells

#### Async layout




