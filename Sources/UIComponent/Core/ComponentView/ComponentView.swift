//  Created by Luke Zhao on 8/27/20.

/// A `PlatformView` that can render components.
/// It provides simple access to the properties and method of the underlying ``ComponentEngine``
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
open class ComponentView: PlatformView, ComponentDisplayableView {
#if os(macOS)
    public override var isFlipped: Bool { true }
#endif
}

/// A `PlatformScrollView` that can render components
/// It provides simple access to the properties and method of the underlying ``ComponentEngine``
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
#if os(macOS)
open class ComponentScrollView: PlatformScrollView {}
#elseif canImport(UIKit)
open class ComponentScrollView: PlatformScrollView, ComponentDisplayableView {}
#endif
