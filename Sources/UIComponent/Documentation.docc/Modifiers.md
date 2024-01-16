# Modifiers

List of all built-in modifiers

## Overview

Modifiers are a way to customize the behavior of a component. They can be chained together to produce a different version of the original component.

### Custom Modifier

To write a custom modifier.
```swift
extension Component {
    func applyShadow() -> some Component {
        ShadowComponent(content: self)
    }
}
```

### Size modifiers

@Links(visualStyle: list) {
- ``Component/size(_:)``
- ``Component/size(width:height:)``
}
