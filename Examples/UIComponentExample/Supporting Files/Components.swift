//  Created by y H on 2021/7/21.

import UIComponent
import UIKit

class Box: ComponentBuilder {
    let width: CGFloat
    let height: CGFloat
    let text: String
    init(_ text: String, width: CGFloat = 40, height: CGFloat = 40) {
        self.width = width
        self.height = height
        self.text = text
    }
    convenience init(_ index: Int, width: CGFloat = 40, height: CGFloat = 40) {
        self.init("\(index)", width: width, height: height)
    }
    convenience init(width: CGFloat = 40, height: CGFloat = 40) {
        self.init("", width: width, height: height)
    }
    func build() -> Component {
        Space(width: width, height: height).styleColor(.systemBlue).overlay(Text(text).textColor(.white).textAlignment(.center).size(width: .fill, height: .fill))
    }
}
