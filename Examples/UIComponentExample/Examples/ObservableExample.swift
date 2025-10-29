//  Created by Luke Zhao on 10/29/25.

import UIKit
import UIComponent

/// In iOS 26, UIViewController has built-in support for observing @Observable objects.
/// Just override updateProperties() to update your component when any observed property changes.
@available(iOS 26.0, *)
class ObservableViewController: UIViewController {
    @Observable
    private class ViewModel {
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

/// Same can be done in UIView subclasses by overriding updateProperties().
/// Here is an example UIView that uses @Observable to update its component.
@available(iOS 26.0, *)
class CountExampleView: ComponentView {
    @Observable private class ViewModel {
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
