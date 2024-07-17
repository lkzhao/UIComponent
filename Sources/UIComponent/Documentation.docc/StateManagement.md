# Responding to State changes

@Metadata {
    @PageImage(
        purpose: card, 
        source: "StateManagement")
}

State management and UI updates

Unlike SwiftUI, UIComponent doesn't have any state management constructs like ``State``, ``Observable``, or ``Binding``. This is by design to keep the framework simple with as few concepts as possible. The responsibility of updating UI is on you whenever the state of your application changes.

We recommend writing a `reloadComponent` method and update the `component` field whenever the state changes. This ensures that the UI is always up to date with the latest state.

```swift
struct MyViewModel {
    var count: Int = 0
}
class MyViewController: UIViewController {
    var viewModel = MyViewModel() {
        didSet {
            reloadComponent()
        }
    }
    func viewDidLoad() {
        super.viewDidLoad()
        reloadComponent()
    }
    func reloadComponent() {
        view.componentEngine.component = VStack {
            Text("Count: \(viewModel.count)")
            Text("Increase").tappableView { [weak self] in
                self?.viewModel.count += 1
            }
        }
    }
}
```

### Performance
You might be thinking that recreating the entire Component tree every time is inefficient. Especially when there are thousands of views. But you might be surprised to know how fast they really are.

There are a few reasons to why this is quick to do.
* Components are swift value types, which are super cheap to construct because they are statically created on the stack rather than on the heap.
* Although the Component tree is recreated, UIComponent can smartly compare the old Component tree with the new one, and only applies the changes to the UIView hierarchy. This is similar to how [React's Virtual DOM](https://legacy.reactjs.org/docs/faq-internals.html) works.
* Expensive UIViews are not created unless they become visible.
* UIComponent can also recycle the views that are no longer visible. This is similar to how the ``UITableView`` works.

If you are worried about performance, there are are few optimization tricks that you can follow in <doc:PerformanceOptimization>.

### Handling Local State

For complex UI, sometimes you don't want to propergate every action to the top level. If this is the case, we recommend creating a custom View that manages the local state.

```swift
class ProfileCell: UIView {
    // external state
    var profile: Profile?  {
        didSet {
            guard profile != oldValue else { return }
            loadImage()
            reloadComponent()
        }
    }
    // internal state
    private var profileImage: UIImage? {
        didSet {
            guard image != oldValue else { return }
            reloadComponent()
        }
    }

    func reloadComponent() {
        componentEngine.component = VStack {
            HStack {
                Image(profileImage ?? UIImage(named: "placeholder")!)
                    .size(width: 50, height: 50)
                    .roundedCorner()
                Text(profile.name).flex()
            }
        }
    }

    func loadImage() {
        guard let profile else { return }
        Task {
            profileImage = try? await ImageLoader.loadImage(profile.imageURL)
        }
    }
}
```

Then you can use it like:

```swift
VStack {
    for profile in profiles {
        ViewComponent<ProfileCell>()
            .profile(profile)
            .size(width: .fill, height: 100)
    }
}
```

### Architecture recommendation

Because UIComponent doesn't have its own state management solution, it should work well with most exist application architecture solutions. 

We do recommend using a redux-like uni-directional application architecture to manage the state of your application. This gives your application a centralized state management system. Checkout the [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) if you are interested in this topic.
