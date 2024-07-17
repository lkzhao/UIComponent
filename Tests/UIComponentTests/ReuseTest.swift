//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent
import UIKit

final class ReuseTests: XCTestCase {
    var view: UIView!
    override func setUp() {
        view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicReuse() {
        view.componentEngine.component = Text("1")
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = VStack {
            Text("2")
        }
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenReuseStrategyDiffers() {
        view.componentEngine.component = Text("1").reuseStrategy(.key("myLabel"))
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = Text("2")
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategy() {
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = VStack {
            Text("2").reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponentOfView() {
        view.componentEngine.component = Text("1").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = VStack {
            Text("2").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponent() {
        view.componentEngine.component = Text("1").eraseToAnyComponent().reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = VStack {
            Text("2").eraseToAnyComponent().reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testReuseWithSameAttributes() {
        view.componentEngine.component = Text("1").backgroundColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        view.componentEngine.component = Text("2").backgroundColor(.blue)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWithDifferentAttributes() {
        view.componentEngine.component = Text("1").textColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        view.componentEngine.component = Text("2")
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithDifferentAttributesAndAnyComponentOfView() {
        view.componentEngine.component = Text("1").textColor(.red).eraseToAnyComponentOfView()
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        view.componentEngine.component = Text("2").eraseToAnyComponentOfView()
        view.componentEngine.reloadData()
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithSameAttributes() {
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red).id("1")
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        view.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red).id("2")
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithViewComponent() {
        let label1 = UILabel()
        label1.text = "1"
        let label2 = UILabel()
        label2.text = "2"
        view.componentEngine.component = ViewComponent(view: label1).textColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        XCTAssertEqual(existingLabel, label1)
        view.componentEngine.component = ViewComponent(view: label2).textColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")
        XCTAssertEqual(newLabel?.textColor, .red)
        XCTAssertEqual(newLabel, label2)
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testStructureIdentity() {
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let existingLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        view.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red)
        view.componentEngine.reloadData()
        XCTAssertEqual(view.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(view.subviews.count, 1)
        let newLabel = view.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // Although the UILabels are using no reuse, they have the same structure identity, so they should be the same instance
        XCTAssertEqual(existingLabel, newLabel)
    }
}
