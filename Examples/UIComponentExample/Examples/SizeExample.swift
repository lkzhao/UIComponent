//  Created by Luke Zhao on 10/17/21.

import UIComponent
import UIKit

class SizeExampleViewController: ComponentViewController {
    override var component: any Component {
        Text("Test").backgroundColor(.red).textColor(.green).centered().size(width: 200, height: 200).backgroundColor(.green)
    }
}
