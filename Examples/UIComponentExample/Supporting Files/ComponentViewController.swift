//  Created by Luke Zhao on 6/14/21.

import UIComponent
import UIKit

class ComponentViewController: UIViewController {
    let componentView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        componentView.contentInsetAdjustmentBehavior = .always
        view.backgroundColor = .systemBackground
        view.addSubview(componentView)
        reloadComponent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        componentView.frame = view.bounds
    }

    func reloadComponent() {
        componentView.componentEngine.component = component
    }

    var component: any Component {
        VStack(justifyContent: .center, alignItems: .center) {
            Text("Empty")
        }
        .size(width: .fill)
    }
}
