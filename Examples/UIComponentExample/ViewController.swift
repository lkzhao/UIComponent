//  Created by Luke Zhao on 2018-12-13.

import UIComponent
import UIKit

class ViewController: ComponentViewController {
    override var component: any Component {
        VStack {
            Join {
                ExampleItem(name: "Card Example", viewController: CardViewController())
                ExampleItem(name: "Card Example 2", viewController: CardViewController2())
                ExampleItem(name: "Card Example 3", viewController: CardViewController3())
                ExampleItem(name: "AsyncImage Example", viewController: UINavigationController(rootViewController: AsyncImageViewController()))
                ExampleItem(name: "Flex Layout Example", viewController: FlexLayoutViewController())
                ExampleItem(name: "Waterfall Layout Example", viewController: WaterfallLayoutViewController())
                ExampleItem(name: "Badge Example", viewController: BadgeViewController())
                ExampleItem(name: "Complex Example", viewController: ComplexLayoutViewController())
                ExampleItem(name: "Custom Layout Example", viewController: GalleryViewController())
                ExampleItem(name: "Size Example", viewController: SizeExampleViewController())
                ExampleItem(name: "SwiftUI Example", viewController: SwiftUIExampleViewController())
            } separator: {
                Separator()
            }
        }.viewController(self)
    }
}

struct ExampleItem: ComponentBuilder {
    @Environment(\.viewController)
    var parentViewController: UIViewController?

    let name: String
    let viewController: () -> UIViewController

    init(name: String, viewController: @autoclosure @escaping () -> UIViewController) {
        self.name = name
        self.viewController = viewController
    }

    func build() -> some Component {
        VStack {
            Text(name)
        }
        .inset(20)
        .tappableView { [weak parentViewController] in
            print("Test")
            parentViewController?.present(viewController(), animated: true)
        }
    }
}

struct ViewControllerEnvironmentKey: EnvironmentKey {
    static var defaultValue: UIViewController? {
        nil
    }
    static var isWeak: Bool {
        true
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { self[ViewControllerEnvironmentKey.self] }
        set { self[ViewControllerEnvironmentKey.self] = newValue }
    }
}

extension Component {
    func viewController(_ viewController: UIViewController) -> some Component {
        environment(\.viewController, value: viewController)
    }
}
