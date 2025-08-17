# Environment Values

Pass data through the component hierarchy using environment values.

## Overview

UIComponent's environment system provides a way to pass data down through the component hierarchy without explicitly passing it through every component. This is particularly useful for configuration values, themes, or other context that many components need access to.

The environment system is similar to SwiftUI's environment, providing type-safe access to shared values throughout your component tree.

## Benefits of Using Environment

- **Implicit data flow**: Pass data through the component hierarchy without manually threading it through every component
- **Type safety**: Environment values are type-safe and checked at compile time
- **Performance**: Environment values are efficiently managed and only computed when needed
- **Flexibility**: Easy to add new environment values without changing existing component interfaces
- **Testability**: Environment values can be easily mocked or overridden for testing

## Basic Usage

### Accessing Environment Values

In your ``Component`` or ``ComponentBuilder``, use the ``Environment`` property wrapper to create a property that can access environment values:

```swift
struct MyComponent: Component {
    @Environment(\.font) var font: UIFont
    @Environment(\.hostingView) var hostingView: UIView?
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        Text("Hello World")
            .font(font) // Use the environment font
            .layout(constraint)
    }
}
```

### Setting Environment Values

UIComponent provides two ways to set environment values for your component hierarchy:

#### Method 1: Convenience Modifiers (Recommended)

For common environment values, use the dedicated convenience modifiers:

```swift
VStack {
    MyComponent() // Will use the custom font and color
    Text("Another text") // Will also use the custom font and color
}
.font(UIFont.boldSystemFont(ofSize: 20))
.textColor(.systemBlue)
```

#### Method 2: Direct Environment Modifier

Use the `.environment()` modifier for custom values or when a convenience modifier doesn't exist:

```swift
VStack {
    MyComponent()
    Text("Another text")
}
.environment(\.font, value: UIFont.boldSystemFont(ofSize: 20))
.environment(\.textColor, value: UIColor.systemBlue)
```

**When to use each approach:**
- **Use convenience modifiers** (`.font()`, `.textColor()`, etc.) for all built-in environment values. They provide better readability and discoverability.
- **Use `.environment()`** when working with custom environment values or when no convenience modifier exists.

## Built-in Environment Values

UIComponent provides several built-in environment values:

### Font Environment

The font environment allows you to set a default font for text components:

```swift
VStack {
    Text("Title") // Will use bold 24pt font
    Text("Subtitle") // Will use bold 24pt font
    Text("Body").font(.systemFont(ofSize: 16)) // Overrides environment font
}
.font(.boldSystemFont(ofSize: 24))
```

### Text Color Environment

The text color environment allows you to set a default text color for text components:

```swift
VStack {
    Text("Title") // Will use red text color
    Text("Subtitle") // Will use red text color
    Text("Body").textColor(.blue) // Overrides environment text color
}
.textColor(.red)
```

### Hosting View Environment

Access the current hosting view (the UIView that contains your components):

```swift
struct CustomComponent: Component {
    @Environment(\.hostingView) var hostingView: UIView?
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        // Access hosting view properties
        let isDarkMode = hostingView?.traitCollection.userInterfaceStyle == .dark
        
        return Text("Hello")
            .textColor(isDarkMode ? .white : .black)
            .layout(constraint)
    }
}
```

### TappableView Configuration

Configure default behavior for tappable components:

```swift
VStack {
    Text("Button 1").tappableView { print("Tapped 1") }
    Text("Button 2").tappableView { print("Tapped 2") }
}
.tappableViewConfig(TappableViewConfig(
    highlightColor: .systemBlue.withAlphaComponent(0.2),
    animationDuration: 0.1
))
```

## Creating Custom Environment Values

### Step 1: Define an Environment Key

Create a type conforming to `EnvironmentKey`:

```swift
struct CurrentUserEnvironmentKey: EnvironmentKey {
    public typealias Value = User?
    public static let defaultValue: User? = nil
}
```

### Step 2: Extend EnvironmentValues

Add a convenient accessor to `EnvironmentValues`:

```swift
extension EnvironmentValues {
    var currentUser: User? {
        get { self[CurrentUserEnvironmentKey.self] }
        set { self[CurrentUserEnvironmentKey.self] = newValue }
    }
}
```

### Step 3: Add a Component Modifier (Recommended)

Create a convenient modifier for setting the environment value:

```swift
extension Component {
    func currentUser(_ user: User?) -> EnvironmentComponent<User?, Self> {
        environment(\.currentUser, value: user)
    }
}
```

**When to create convenience modifiers:**
- **Do create** for values used across multiple features or components
- **Do create** for core design system values (themes, spacing, etc.)
- **Don't create** for one-off, localized values that would clutter the API

### Step 4: Use the Environment Value

Use the `@Environment` property wrapper to access the environment value, and apply it using either the convenience modifier or direct environment modifier:

```swift
struct UserProfileComponent: Component {
    // Use the `@Environment` property wrapper to access the environment value
    @Environment(\.currentUser) var user: User?
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        if let user = user {
            return VStack(spacing: 8) {
                Text("Welcome, \(user.name)!")
                    .font(.boldSystemFont(ofSize: 18))
                Text(user.email)
                    .font(.systemFont(ofSize: 14))
                    .textColor(.secondaryLabel)
            }.layout(constraint)
        } else {
            return Text("Please log in")
                .textColor(.secondaryLabel)
                .layout(constraint)
        }
    }
}
```

## Real-World Example: Theme System

For a comprehensive example showing how to implement a theme system using environment values, see the **Theme System** example in the UIComponent Examples project:

[`Examples/UIComponentExample/Examples/Theme System/ThemeSystemViewController.swift`](https://github.com/lkzhao/UIComponent/tree/master/Examples/UIComponentExample/Examples/Theme%20System/ThemeSystemViewController.swift)

This example demonstrates:
- **Custom environment keys** for theme data
- **Environment value propagation** through component hierarchy
- **Themed components** that automatically adapt to environment changes
- **Dynamic theme switching** with live UI updates
- **Type-safe environment access** with `@Environment` property wrapper
- **Component modifier patterns** for setting environment values

## Advanced Usage

### Environment Composition

You can compose multiple environment values:

```swift
VStack {
    MyComplexComponent()
}
.theme(.dark)                                    // Custom convenience modifier
.currentUser(currentUser)                       // Custom convenience modifier
.font(.systemFont(ofSize: 18))                  // Built-in convenience modifier
.environment(\.customDebugMode, value: true)    // Direct modifier for values without convenience methods
```

### Dynamic Environment Values

Environment values can be computed dynamically:

```swift
struct ResponsiveComponent: Component {
    @Environment(\.hostingView) var hostingView: UIView?
    
    private var isCompact: Bool {
        hostingView?.traitCollection.horizontalSizeClass == .compact
    }
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        if isCompact {
            VStack { /* Compact layout */ }
        } else {
            HStack { /* Regular layout */ }
        }.layout(constraint)
    }
}
```

## Best Practices

1. **Prefer convenience modifiers**: Use built-in convenience modifiers (`.font()`, `.textColor()`) for better readability and discoverability
2. **Use environment for widely-shared data**: Configuration, themes, user context, etc.
3. **Provide sensible defaults**: Always define meaningful default values in your environment keys
4. **Keep environment values immutable**: Prefer value types and avoid mutable reference types
5. **Don't overuse environment**: For data that's only used by one or two components, consider passing it directly
6. **Create convenience modifiers judiciously**: Only add them for frequently-used or widely-applicable values
7. **Document your environment values**: Make it clear what each environment value is for and when to use it
8. **Consider performance**: Environment values are efficient, but avoid creating new values unnecessarily

## See Also

- ``EnvironmentKey``
- ``EnvironmentValues`` 
- ``EnvironmentComponent``
- ``Environment``
- <doc:StateManagement>