# Custom Component

Learn how to create custom components

## Overview

To create a custom component, you need to write a struct that conforms to ``Component`` protocol.
The only method that is required is the ``Component/layout(_:)`` method which takes in a ``Constraint`` and returns a ``RenderNode``

```swift
struct MyComponent: Component {
    func layout(_ constraint: Constraint) -> some RenderNode {
        // layout code
    }
}
```

Most of the time, you can directly compose other Components inside your custom component, without the need to calculate layout or write your own RenderNode. Just call the ``Component/layout(_:)`` at the end of your child component to produce a RenderNode.

```swift
struct ProfileComponent: Component {
    func layout(_ constraint: Constraint) -> some RenderNode {
        VStack {
            Text("Luke Zhao")
            Text("iOS Developer")
        }.layout(constraint)
    }
}
```

UIComponent also provides a simpler ``ComponentBuilder`` protocol. Instead of writing the ``Component/layout(_:)`` method, it allows you to write a ``ComponentBuilder/build()`` method to produce a child component.

```swift
struct ProfileComponent: ComponentBuilder {
    let profile: Profile
    func build() -> some Component {
        VStack {
            Text(profile.name)
            Text(profile.role)
        }
    }
}

// Usage
componentView.component = ProfileComponent(profile: myProfile)
```

##### Custom Layout Component

To implement a custom layout component is quite easy. Similar to the examples above, you will only need to write the ``Component/layout(_:)`` method. Inside the layout method, calculate the frame of the children. And return a RenderNode that stores the layout information along with the RenderNodes of the children.


There are a 4 built-in layout RenderNode types that you can use.
- ``VerticalRenderNode``
    * Renders children when they are inside the visible frame. 
    * This is optimized for a vertical list. It uses binary search to check which children are visible.
    * Children must be sorted by their y position value.
    * Needs to provide a ``StackRenderNode/mainAxisMaxValue`` with the max height of the children.
- ``HorizontalRenderNode``
    * Renders children when they are inside the visible frame. 
    * This is optimized for a horizontal list. It uses binary search to check which children are visible.
    * Children must be sorted by their x position value.
    * Needs to provide a ``StackRenderNode/mainAxisMaxValue`` with the max width of the children.
- ``SlowRenderNode``
    * Renders children when they are inside the visible frame. 
    * This is slow since it needs to loop through all children to check whether they are inside the visible frame.
- ``AlwaysRenderNode``: 
    * Renders all children all the time.

These RenderNodes also need the following data:
* ``RenderNode/size``: Size of the component
* ``RenderNode/children-42h1l``: RenderNodes of the children
* ``RenderNode/positions-6f59e``: Positions of the children

Below is an example of a simple custom VStack without spacing.
```swift
struct MyVStack: Component {
    let children: [any Component]
    func layout(_ constraint: Constraint) -> some RenderNode {
        var childrenRenderNodes: [RenderNode] = []
        var childrenPositions: [CGPoint] = []
        var currentOffset = 0.0
        var maxChildWidth = 0.0
        var maxChildHeight = 0.0
        for child in children {
            let childRenderNode = child.layout(constraint)
            let childPosition = CGPoint(x: 0, y: currentOffset)
            currentOffset += child.size.height
            childrenRenderNodes.append(childRenderNode)
            childrenPositions.append(childPosition)
            maxChildWidth = max(maxChildWidth, child.size.width)
            maxChildHeight = max(maxChildHeight, child.size.height)
        }
        let size = CGSize(width: maxChildWidth, height: currentOffset)
        return VerticalRenderNode(size: size, children: childrenRenderNodes, positions: childrenPositions, mainAxisMaxValue: maxChildHeight)
    }
}
```


##### Custom View Component

WIP
