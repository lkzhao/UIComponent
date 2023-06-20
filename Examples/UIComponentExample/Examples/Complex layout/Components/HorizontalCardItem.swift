//  Created by y H on 2021/7/21.

import UIComponent
import UIKit.UIScreen
import UIKit.UITraitCollection

struct HorizontalCardItem: ComponentBuilder {

    let data: Context

    func build() -> some Component {
        HStack(spacing: 10, alignItems: .center) {
            VStack(spacing: 5, justifyContent: .center, alignItems: .center) {
                Image(systemName: "hand.tap")
                Text("Tap to delete", font: .systemFont(ofSize: 10))
            }
            .inset(10).size(width: .aspectPercentage(1), height: .fill).styleColor(data.fillColor)
            VStack(justifyContent: .spaceAround) {
                Text("This is a title").flex()
                HStack(spacing: 5, alignItems: .center) {
                    Text("This is a description", font: .systemFont(ofSize: 14)).textColor(.secondaryLabel).flex()
                    Image(systemName: "checkmark.shield.fill")
                }
                .flex()
            }
            .flex()
        }
        .inset(10).size(width: 300, height: 100).styleColor(data.fillColor).id(data.id)
    }
}

extension HorizontalCardItem {
    struct Context: Equatable {
        let id: String = UUID().uuidString
        let fillColor = UIColor.randomSystemColor()
    }
}
