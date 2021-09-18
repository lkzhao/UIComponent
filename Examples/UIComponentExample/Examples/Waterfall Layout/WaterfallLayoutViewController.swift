//  Created by Luke Zhao on 7/23/21.

import UIComponent
import UIKit.UIButton

class WaterfallLayoutViewController: ComponentViewController {
  typealias WaterfallItem = (size: CGSize, color: UIColor)

  lazy var waterfallData: [WaterfallItem] = {
    var sizes = [(CGSize, UIColor)]()
    for _ in 1...30 {
      sizes.append((CGSize(width: Int(arc4random_uniform(300 - 100)) + 100, height: Int(arc4random_uniform(300 - 100)) + 100), .randomSystemColor()))
    }
    return sizes
  }()

  override var component: Component {
    VStack(spacing: 20) {
      Text("Waterfall layouts", font: .boldSystemFont(ofSize: 20)).id("label3")
      VStack(spacing: 10) {
        Text("Horizontal waterfall").inset(left: 10)
        HorizontalWaterfall(columns: 3, spacing: 5) {
          for (index, data) in self.waterfallData.enumerated() {
            Space().size(width: .aspectPercentage(data.size.width / data.size.height), height: .fill).styleColor(data.color).overlay(Text("\(index)").textAlignment(.center))
          }
        }
        .inset(h: 10).size(height: .absolute(300)).scrollView().showsHorizontalScrollIndicator(false)
      }
      .inset(v: 10).styleColor(.systemGroupedBackground).id("Waterfall1")

      VStack(spacing: 10) {
        Text("Vertical waterfall").inset(left: 10)
        Waterfall(columns: 3, spacing: 5) {
          for (index, data) in waterfallData.enumerated() {
            let size = data.size
            Space().size(width: .fill, height: .aspectPercentage(size.height / size.width)).styleColor(data.color).overlay(Text("\(index)").textAlignment(.center))
          }
        }
        .inset(h: 10).size(width: .fill)
      }
      .inset(v: 10).styleColor(.systemGroupedBackground).id("Waterfall2")

    }
    .inset(20)
  }
}
