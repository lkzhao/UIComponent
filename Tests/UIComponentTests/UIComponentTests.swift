//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent

let text1 = "This is a test of layout methods"
let text2 = "This is a test of layout"
let font = UIFont.systemFont(ofSize: 16)
let maxSize = CGSize(width: 100, height: CGFloat.infinity)

final class UIComponentTests: XCTestCase {
    func testPerfHStackText() {
        let componentView = ComponentView()
        measure {
            componentView.component = HStack {
                for _ in 0..<10000 {
                    Text("Test")
                }
            }
            componentView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 600))
            componentView.layoutIfNeeded()
        }
    }
    func testPerfTextLayout() {
        measure {
            for _ in 0..<1000 {
                let attrText = NSAttributedString(string: text1, attributes: [.font: font])
                _ = attrText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil).size
                let attrText2 = NSAttributedString(string: text2, attributes: [.font: font])
                _ = attrText2.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil).size
            }
        }
    }
    func testPerfUILabelLayout() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        measure {
            for _ in 0..<1000 {
                label.text = text1
                _ = label.sizeThatFits(maxSize)
                label.text = text2
                _ = label.sizeThatFits(maxSize)
            }
        }
    }
    func testPerfNewUILabelLayout() {
        measure {
            for _ in 0..<1000 {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 16)
                label.text = text1
                _ = label.sizeThatFits(maxSize)
                let label2 = UILabel()
                label2.font = UIFont.systemFont(ofSize: 16)
                label2.text = text2
                _ = label2.sizeThatFits(maxSize)
            }
        }
    }
}
