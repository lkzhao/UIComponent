# Installation

@Metadata {
    @PageImage(
        purpose: card, 
        source: "Installation")
}

Learn how to install the UIComponent framework

## Overview

### Through Xcode

1. Open your project in Xcode
2. Go to __File__ > __Add Package Dependencies...__
3. Enter the repository URL: `https://github.com/lkzhao/UIComponent`
4. Click on __Add Package__
5. Import UIComponent to the top of your file
```swift
import UIComponent
```

## Requirements

- iOS 13.0+
- macOS 12.0+
- tvOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Quick Start

After installation, you can start using UIComponent in any `PlatformView`:

```swift
import UIComponent

final class MyHostingView: PlatformView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        reloadComponent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        reloadComponent()
    }

    private func reloadComponent() {
        componentEngine.component = VStack(spacing: 16) {
            Text("Welcome to UIComponent!")
                .font(.systemFont(ofSize: 24))
                .textColor(.systemBlue)

            Text("A modern declarative UI framework for UIKit/AppKit")
                .font(.systemFont(ofSize: 16))
                .textColor(.systemGray)
                .textAlignment(.center)
        }
        .inset(20)
    }
}
```

### Through Package.swift

Add the following to your `Package.swift` file under `dependencies`:

```swift
.package(url: "https://github.com/lkzhao/UIComponent", from: "5.0.0"),
```

Add `"UIComponent"` to your target's dependencies.
```swift
.target(
    name: "MyPackage",
    dependencies: [
        "UIComponent", // Add this
    ]),
```


###### Example Package.swift:
```swift
let package = Package(
    name: "MyPackage",
    platforms: [
        .iOS("13.0"),
        .macOS("12.0"),
        .tvOS("15.0")
    ],
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lkzhao/UIComponent", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: [
                "UIComponent", // Add this
            ]),
    ]
)

```
