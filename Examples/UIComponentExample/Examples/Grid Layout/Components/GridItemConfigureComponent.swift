//  Created by `y H` on 2022/4/6.

import UIComponent
import UIKit

struct GridItemConfigureComponent: ComponentBuilder {
  let gridFlow: GridFlow
  let tapAddNewItem: (TappableView) -> Void
  let tapShuffle: () -> Void
  let tapGridPreferencesPopver: (TappableView) -> Void
  func items() -> ComponentArrayContainer {
    Join {
      Image(systemName: "plus")
        .tintColor(.white)
        .inset(5)
        .tappableView(tapAddNewItem)
        .cornerRadius(5)
        .cornerCurve(.continuous)
        .backgroundColor(.systemBlue)
      Image(systemName: "shuffle")
        .tintColor(.white)
        .inset(5)
        .tappableView(tapShuffle)
        .cornerRadius(5)
        .cornerCurve(.continuous)
        .backgroundColor(.systemBlue)
      Image(systemName: "gear")
        .tintColor(.white)
        .inset(5)
        .tappableView(tapGridPreferencesPopver)
        .cornerRadius(5)
        .cornerCurve(.continuous)
        .backgroundColor(.systemBlue)
    } separator: {
      Space()
    }
  }

  func build() -> Component {
    if gridFlow == .columns {
      return VStack(spacing: 10, alignItems: .center) {
        items()
      }
    } else {
      return HStack(spacing: 10, alignItems: .center) {
        items()
      }
    }
  }
}
