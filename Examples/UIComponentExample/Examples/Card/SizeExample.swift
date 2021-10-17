//  Created by Luke Zhao on 10/17/21.

import UIComponent
import UIKit

class SizeExampleViewController: ComponentViewController {
  override var component: Component {
    Flow {
      Space(width: 50, height: 50).view().backgroundColor(.red).centered().size(CGSize(width: 200, height: 200))
    }
  }
}
