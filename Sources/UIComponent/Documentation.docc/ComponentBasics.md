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
// Basic rendering
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
```

### SwiftUI Integration (v5.0+)

UIComponent can seamlessly integrate SwiftUI views alongside UIKit components. UIComponent's result builder is configured to automatically wrap native SwiftUI views, making integration seamless without requiring explicit wrappers for simple cases:

```swift
VStack(spacing: 16) {
    // UIComponent Text
    Text("Mixed UI Example")
        .font(.boldSystemFont(ofSize: 20))
        .textColor(.label)
    
    // SwiftUI Text directly (automatically wrapped by result builder)
    SwiftUI.Text("Hello from SwiftUI!")
        .foregroundColor(.blue)
    
    // Complex SwiftUI content wrapped in SwiftUIComponent
    SwiftUIComponent {
        SwiftUI.HStack {
            SwiftUI.Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            SwiftUI.Text("Rating: 5.0")
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Custom SwiftUI View
    SwiftUIComponent(CustomGradientView())
        .size(width: .fill, height: 100)
    
    // UIComponent modifiers work on SwiftUI content
    SwiftUIComponent {
        SwiftUI.Text("Styled SwiftUI")
            .font(.headline)
    }
    .backgroundColor(.systemBlue)
    .with(\.layer.cornerRadius, 8)
    .inset(12)
}

struct CustomGradientView: View {
    var body: some View {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
        .overlay(
            Text("SwiftUI Gradient")
                .foregroundColor(.white)
                .font(.headline)
        )
    }
}
```

This demonstrates:
- **Direct SwiftUI usage** without wrapping
- **SwiftUIComponent wrapper** for complex content
- **UIComponent modifiers** applied to SwiftUI views
- **Custom SwiftUI views** with size control

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
