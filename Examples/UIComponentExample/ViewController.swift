//  Created by Luke Zhao on 2018-12-13.

import UIComponent
import UIKit

class ViewController: ComponentViewController {
    override var component: Component {
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
            } separator: {
                Separator()
            }
        }
    }
}

struct ExampleItem: ComponentBuilder {
    let name: String
    let viewController: () -> UIViewController
    init(name: String, viewController: @autoclosure @escaping () -> UIViewController) {
        self.name = name
        self.viewController = viewController
    }
    func build() -> Component {
        VStack {
            Text(name)
        }
        .inset(20)
        .tappableView {
            $0.present(viewController())
        }
    }
}
