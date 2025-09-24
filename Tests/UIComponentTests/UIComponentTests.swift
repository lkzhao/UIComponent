//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent

let text1 = "This is a test of layout methods, performance, and correctness."
let text2 = "This is a test of layout"
let font = UIFont.systemFont(ofSize: 16)
let maxSize = CGSize(width: 100, height: CGFloat.infinity)

final class UIComponentTests: XCTestCase {
    func testPerfHStackText() {
        let view = UIView()
        measure {
            view.componentEngine.component = HStack {
                for _ in 0..<10000 {
                    Text("Test")
                }
            }
            view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
            view.layoutIfNeeded()
        }
    }

    func testVisibleInsets() {
        let view = UIView()
        view.componentEngine.component = VStack(spacing: 100) {
            Text(text1).size(width: 300, height: 300)
            Text(text2).size(width: 300, height: 300)
        }.inset(100).visibleInset(-100)
        view.frame = CGRect(x: 0, y: 0, width: 500, height: 400)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)
        view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 2)
    }

    func testOffsetVisibility() {
        // Offset shouldn't adjust visibility, it should use the original frame for visibility testing
        let view = UIView()
        view.componentEngine.component = ZStack {
            Text(text1).size(width: 300, height: 300).offset(CGPoint(x: 0, y: 300))
        }
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)

        view.bounds = CGRect(x: 0, y: 300, width: 300, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 0)
    }
    func testTextColor() {
        let view = UIView(frame: .init(origin: .zero, size: CGSize(width: 200, height: 200)))
        view.componentEngine.component = Text("Test").textColor(.red)
        view.layoutIfNeeded()
        XCTAssertEqual((view.subviews.first as! UILabel).textColor, .red)
        view.componentEngine.component = Text("Test").with(\.textColor, .green)
        view.layoutIfNeeded()
        XCTAssertEqual((view.subviews.first as! UILabel).textColor, .green)
        view.componentEngine.component = Text("Test").environment(\.textColor, value: .yellow)
        view.layoutIfNeeded()
        XCTAssertEqual((view.subviews.first as! UILabel).textColor, .yellow)
        view.componentEngine.component = HStack {
            Text("Test")
        }.textColor(.blue)
        view.layoutIfNeeded()
        XCTAssertEqual((view.subviews.first as! UILabel).textColor, .blue)
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
