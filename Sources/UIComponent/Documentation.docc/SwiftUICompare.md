# UIComponent vs SwiftUI

Discover the pros and cons of UIComponent compare to SwiftUI

## Overview

SwiftUI sparked the creation of UIComponent. In the early days of SwiftUI, it was somewhat unstable and lacking features. UIComponent was created at the time to integrate SwiftUI's resultBuilder syntax with UIKit. Providing UIKit engineers a modern and declarative way to build UI.

Both SwiftUI and UIComponent have evolved since then. But there are still some differences between the two. This section will help you understand the pros and cons of each framework, and how you can choose what frameworks to use.

## Platform supports
| | UIComponent | SwiftUI
| --- | --- | ---|
Platform Support |iOS, macCatalyst, tvOS, visionOS | All apple platforms
Widget Support | No | Yes

## Similarities
* Both are declarative UI framework
* Both uses resultBuilders
* Both uses value type (struct) to define UI.

### UIComponent Advantages:
* Seamless intergration with UIKit
* Better performance on list:
    * Global cell reuse
    * Renders only the visible views
    * Supports background thread layout
* Simple to understand
    * Unidirectional data flow
    * UI only. No state management nor two way binding
    * Open Source
* More control over the layout and render process
    * Easier to build advanced features
    * Less stuggle when SwiftUI's View doesn't support a particular feature.
* Support `for-loop` and `switch` statement in the result builder
* Support ViewController transitions
* Less buggy compare to SwiftUI (Even on iOS 17)
* Support lower iOS versions
* Can be updated without an OS update

### SwiftUI Advantage
* All platform support
* More learning resources
* Future proof
* Local state management
* More out-of-the-box Views
* Support custom shaders (iOS 17+)

## What to use
Although SwiftUI is the future on Apple platform, UIKit is still under active development and won't be gone any time soon. If you are building a new app from scratch, SwiftUI might be a great choice. However, when getting into complex feature or having performance concerns, UIComponent prove to be a better alternative due to its openness and simpler architecture. 

Keep in mind that both framework can be used together in a single project. It is best to choose the right tool for the right job.
