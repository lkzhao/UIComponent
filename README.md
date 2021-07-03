# UIComponent

### Write UI in crazy speed, with great perf & no limitations.

**SwiftUI** still haven't satisfied my requirements. So I build this.

This framework allows you to build UI based on UIKit using syntax similar to SwiftUI.

You can think about this as an improved collection view that is much easier to use than the default `UICollectionView`.

It also has the following properties:
* Great performance through global cell reuse.
* Built in layouts
* Declaritive API based on `resultBuilder` and modifier syntax.
* Work seemless with existing UIKit views, viewControllers, and transitions.
* `dynamicMemberLookup` support for all `ViewComponent`s which can help you easily update your UIKit views.
* `Animator` API to apply animations when cells are being moved, updated, inserted, or deleted.
* Simple architecture for anyone to be able to understand.
* Easily create your own Components.
* No state management or two-way binding.

If you want to checkout a production app using this framework. Please see the [Noto](https://apps.apple.com/us/app/noto-elegant-note/id1459055246) app. It uses **UIComponent** for all of the UI including text editing. The text editing view is a `ComponentScrollView` with each line rendered as a cell through a custom component.

## How to use

At its core, it provides two `UIView` subclass: `ComponentView` and `ComponentScrollView`.

These two classes takes in a `component` parameter where you use to construct your UI using declarative syntax. You can also apply modifiers to these components and create the look and feel you want.

For example:
```swift
componentView.component =  VStack(spacing: 8) {
  for (index, cardData) in cards.enumerated() {
    Card(card: cardData) { [unowned self] in
      self.cards.remove(at: index)
    }
  }
  AddCardButton { [unowned self] in
    self.cards.append(CardData(title: "Item \(self.newCardIndex)",
                               subtitle: "Description \(self.newCardIndex)"))
    self.newCardIndex += 1
  }
}.inset(20)
```

Result:


Checkout the example project for more indepth examples.

## Built in components

### Layouts

* VStack
* HStack
* Waterfall
* Flow

### View

* Text
* Image
* Separator

### Utility

* ForEach
* Space
* Join

### Useful modifiers

* .inset()
* .size()
* .background()
* .overlay()
* .flex()
* .view()
* .tappableView()
* .scrollView()
