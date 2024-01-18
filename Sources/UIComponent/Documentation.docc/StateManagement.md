# State Management

Manage state changes and trigger UI updates.

UIComponent doesn't have `State` or `Binding` like SwiftUI. Instead, it emphasizes unidirectional data flow. When an event occurs, you should propogate it to the top level `View` or `ViewController` that host the ComponentView and update the `component` field with the new Component hierarchy.

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
    let componentView = ComponentView()
    func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(componentView)
        reloadComponent()
    }
    func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        componentView.frame = view.bounds
    }
    func reloadComponent() {
        componentView.component = VStack {
            Text("Count: \(viewModel.count)")
            Text("Increment").tappableView { [weak self] in
                self?.viewModel.count += 1
            }
        }
    }
}
```

For complex UI, sometimes you don't want to propergate every action to the top level `ViewController`. If this is the case, we recommend creating a custom View that manages the local state.

```swift
class ProfileCell: ComponentView {
    // set externally
    var profile: Profile?  {
        didSet {
            guard profile != oldValue else { return }
            reloadComponent()
        }
    }
    // internal state
    private var isExpanded: Bool = false {
        didSet {
            guard isExpanded != oldValue else { return }
            reloadComponent()
        }
    }
    func reloadComponent() {
        componentView.component = VStack {
            HStack {
                Image(profile.image).size(width: 50, height: 50).roundedCorner()
                Text(profile.name).flex()
                Image(systemName: "chevron.down").tappableView { [weak self] in
                    self?.isExpanded.toggle()
                }
            }
            if isExpanded {
                Text(profile.description)
            }
        }
    }
}
```

> Tip: We recommend using a redux-like unidirectional application architecture to manage the state of your application. Something like the [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) can work really well with UIComponent
