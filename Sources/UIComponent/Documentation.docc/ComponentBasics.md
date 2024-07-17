# Component Basics

Learn how to use ``Component`` to render UI

@Metadata {
    @PageImage(
        purpose: card, 
        source: "ComponentBasics")
}

``Component`` is the basic building block in UIComponent, akin to SwiftUI's `View` type. 

UIComponent provides various layout components (``VStack``, ``HStack``, ``Flow``, ``Waterfall``, ...) and view components (``Text``, ``Image``, ...) out of the box.

A simple UI can be constructed by composing these components together:
```swift
VStack(spacing: 8, alignItems: .center) {
    Image("logo")
    Text("Hello World!")
}
```

![](ComponentBasics)

To render the ``Component`` on a view, assign the component to the ``UIView.componentEngine.component`` property. The view will automatically reload and display the UI.

```swift
view.componentEngine.component = VStack(spacing: 8, alignItems: .center) {
    Image("logo")
    Text("Hello World!")
}
```


### Conditional & List Rendering

Use `if` or `switch` statement to render views conditionally. Or use `for-loop` to render multiple items as a list.

```swift
VStack {
    for item in items {
        if let image = item.image {
            Image(image)
        }
        switch item.type {
            case .fruit:
               Text("Fruit")
            case .vegetable:
               Text("Vegetable")
            }
        }
    }
}
```

### Modifiers

Modifiers are a way to customize the behavior of a component. They can be chained together to produce a different version of the original component.

You can use the modifier syntax to assign values to the Component. Here are some examples:
```swift
// modifiers that update view properties
Text("Hello")
    .font(UIFont.systemFont(ofSize: 20)) // UILabel.font
    .textColor(.red) // UILabel.textColor

Image(image)
    .contentMode(.scaledAspectFit) // UIImageView.contentMode

// modifiers that update layout
Image(image)
    .size(width: 200, height: 200) // force a size
    .inset(top: 8, rest: 12) // add a padding
    .overlay { // display a component as an overlay on top
        Text("Overlay")
            .centered() // center the component inside the bounding box
    }
```

See ``Component`` for an exhaustive list of all built-in modifiers.

#### Custom Modifier

To write a custom modifier. Simply extend the ``Component`` protocol with your own method that returns another ``Component``.
```swift
extension Component {
    // apply a default corner radius of 8
    func applyDefaultCornerRadius() -> some Component {
        with(\.layer.cornerRadius, 8)
    }
    // apply a green background
    func greenBackground() -> some Component {
        backgroundColor(.green)
    }
    // Wrap inside another component
    func specialModifier() -> some Component {
        SpecialComponent(content: self)
    }
}
```

#### Handling User Actions

UIComponent provides a ``Component/tappableView(_:)-ew7m`` modifier that allows you to handle tap actions. Simply wrap your Component with the modifier and provide a closure to handle the tap action.

```swift
Text("Tap Me").tappableView { [weak self] in
    self?.handleTap()
}
```

There are more actions and customization that the tappableView can handle, including doubleTap, longPress, contextMenu, dropping. See ``TappableView`` for more details.

> Tip: For more advanced customization, like gestures, context menu, drag and drop, etc... We recommend creating a custom view to handle them. This allow it to be more flexible and reusable.
