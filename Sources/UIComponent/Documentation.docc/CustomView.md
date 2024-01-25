# Custom View

@Metadata {
    @PageImage(
        purpose: card, 
        source: "CustomView")
}

Learn how to use custom views inside UIComponent

Rendering a custom view inside UIComponent is straightforward.

In fact, UIComponent treats all ``UIKit/UIView`` as components, so you can insert them directly into a Component hierarchy.

```swift
// store this as a property somewhere
let myCustomView = MyCustomView()

// place it in the Component hierarchy
componentView.component = VStack {
    Text("Working with custom view")
    myCustomView
}
```

##### Dynamically Create Custom View (*Preferred)

UIComponent can also create custom views for you at render time. Simply use ``ViewComponent`` with a ``Component/size(width:height:)-199wg`` modifier to render a custom view.

```swift
ViewComponent<MyCustomView>().size(width: 100, height: 100)
```
By default, UIComponent calls the `.init()` initializer when it needs to render the view. However, if your custom view doesn't support the default `.init()` initializer, you can provide a generator to the ``ViewComponent``.

```swift
ViewComponent(generator: MyCustomView(field: field)).size(width: 100, height: 100)
```

Using ``ViewComponent`` offers many benefits:
* Views are not created unless they are visible
* Views can be reused by the system
* Eliminate the need to initialize and store the views separately

Imagine you are rendering a feed with thousands of views. Using ``ViewComponent`` is much faster and uses less memory than creating and storing the views yourself.

> Important: When using a ``ViewComponent``, you should always assign a `size`. Since views are lazily initialized, the layout doesn't know how big the view will take up before rendering it.

##### Updating Custom View

With the power of @dynamicMemberLookup, any field that exists on the View will be exposed as a modifier. This is all automatic, eliminating the needs to define the modifier function yourself.

```swift
class ProfileView: UIView {
    var profile: Profile?
}

// Component that renders a ProfileView with a provided profile
ViewComponent<ProfileView>()
    .profile(profile) // assigning the profile the ProfileView
    .size(width: 100, height: 100)
```
