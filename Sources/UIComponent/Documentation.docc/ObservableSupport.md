# Observable Support in UIKit

Built-in observation for `UIViewController` and `UIView` integrations.

Starting in iOS 26, UIComponent plays nicely with the new Swift Observation system.
``UIViewController`` and ``ComponentView`` automatically track any `@Observable`
state you access inside ``UIViewController/updateProperties()`` or ``ComponentView/updateProperties()``
and re-run those methods whenever the data changes. This lets you treat UIKit surfaces the
same way you would a SwiftUI view: declare the UI from your latest model, and UIComponent
takes care of the rest.

## Observing inside ``UIViewController``

Override ``UIViewController/updateProperties()`` and build your component tree from
observed model data. When any observed property changes, UIComponent renders the
new component automatically.

```swift
@available(iOS 26.0, *)
final class ObservableViewController: UIViewController {
    @Observable
    private final class ViewModel {
        var count: Int = 0
    }

    private let viewModel = ViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel

        view.componentEngine.component = VStack(spacing: 8, justifyContent: .center, alignItems: .center) {
            Text("Hello world!", font: .boldSystemFont(ofSize: 22))
            Text("Count: \(viewModel.count)")
            Text("Increase").tappableView {
                viewModel.count += 1
            }
        }.fill()
    }
}
```

Key details:
- Access every observed value inside `updateProperties()` so UIKit knows what to track.
- Keep calling `super.updateProperties()` to preserve UIKit book-keeping.
- Assign directly to ``ComponentEngine/component``; diffing and view reuse happen automatically.

## Observing inside ``UIView``

The same pattern works for any ``ComponentView`` (a ``UIView`` subclass tailored for
UIComponent). Create an `@Observable` model, override ``ComponentView/updateProperties()``,
and assign to the `component` property.

```swift
@available(iOS 26.0, *)
final class CountExampleView: ComponentView {
    @Observable
    private final class ViewModel {
        var count: Int = 0
    }

    private let viewModel = ViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel

        component = VStack(spacing: 8, justifyContent: .center, alignItems: .center) {
            Text("Hello world!", font: .boldSystemFont(ofSize: 22))
            Text("Count: \(viewModel.count)")
            Text("Increase").tappableView {
                viewModel.count += 1
            }
        }.fill()
    }
}
```

## Tips for adopting Observation

- Scope the observable view model privately inside the view or controller to keep
  the observation graph local to that surface.
- Reassign the entire component tree from your latest model instead of mutating
  existing UIKit views.
- If you support pre-iOS 26, gate your observation-enabled code with availability
  checks and fall back to manual `reloadComponent()` calls on earlier systems.

For a complete, runnable sample, see `ObservableExample.swift` in the Examples
project.
