# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
- `swift build` - Build the UIComponent Swift package
- `swift test` - Run all tests in the package
- `swift test --filter <TestName>` - Run specific test
- Open `Examples/UIComponentExample.xcodeproj` in Xcode to run the example app

## Architecture Overview

UIComponent is a declarative UI framework for UIKit with SwiftUI-like syntax and unidirectional data flow.

### Rendering Components (v4.0+)
**Modern approach:** Render components on any UIView using:
```swift
view.componentEngine.component = VStack {
    Text("Hello World!")
}
```

`ComponentView` and `ComponentScrollView` are deprecated. The `componentEngine` extension on `UIView` (`Sources/UIComponent/Core/ComponentView/UIView+ComponentEngine.swift`) provides:
- Lazy initialization with method swizzling
- Integration with `layoutSubviews`, `setBounds`, `sizeThatFits`
- Special UIScrollView handling for safe areas and content insets

### Core Rendering Flow
1. **Component** - Define UI structure with `layout(_:)` method
2. **RenderNode** - Layout result with size, positions, children
3. **Visibility Test** - `visibleChildren(in frame:)` determines what to render
4. **Renderable** - Maps to actual UIViews in hierarchy
5. **ComponentEngine** - Manages reload/render cycles with diff algorithm

### Key Components
- **Layout Components**: `VStack`/`HStack`/`ZStack` (`Sources/UIComponent/Components/Layout/Stack/`)
- **FlexLayout**: CSS Flexbox-like layouts (`Sources/UIComponent/Components/Layout/Flex/`)
- **View Components**: `Text`, `Image`, `ViewComponent` for custom UIViews
- **Modifiers**: Chainable properties like `.size()`, `.backgroundColor()`, `.tappableView()`

### Performance Features
- **Lazy Loading**: `.lazy(width:height:)` defers layout until needed
- **View Reuse**: Explicit `.reuseKey()` modifier for cell reuse (v5.0+)
- **Async Layout**: `view.componentEngine.asyncLayout = true` for background layout
- **Visibility Testing**: Only renders components within visible bounds

## SwiftUI Integration (v5.0+)
```swift
VStack {
    Text("UIComponent Text")
    SwiftUI.Text("SwiftUI Text").foregroundColor(.red)
    SwiftUIComponent {
        SwiftUI.VStack { /* SwiftUI content */ }
    }.backgroundColor(.black)
}
```

## State Management Pattern
UIComponent doesn't provide built-in state management. Recommended pattern:
```swift
class MyViewController: UIViewController {
    var viewModel = MyViewModel() {
        didSet { reloadComponent() }
    }
    
    func reloadComponent() {
        view.componentEngine.component = VStack {
            Text("Count: \(viewModel.count)")
        }
    }
}
```

## Version Migration Notes
- **v2.0**: Unified Component/ViewComponent, removed `.view()` requirement
- **v4.0**: Any UIView can render components via `componentEngine`
- **v5.0**: SwiftUI integration, explicit view reuse with `.reuseKey()`, context value system