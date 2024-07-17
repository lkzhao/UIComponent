//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent
import UIKit

final class ReuseTests: XCTestCase {
    var componentView: UIView!
    override func setUp() {
        componentView = UIView()
        componentView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicReuse() {
        componentView.componentEngine.component = Text("1")
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = VStack {
            Text("2")
        }
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenReuseStrategyDiffers() {
        componentView.componentEngine.component = Text("1").reuseStrategy(.key("myLabel"))
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = Text("2")
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategy() {
        componentView.componentEngine.component = Text("1").reuseStrategy(.noReuse)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = VStack {
            Text("2").reuseStrategy(.noReuse)
        }
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponentOfView() {
        componentView.componentEngine.component = Text("1").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = VStack {
            Text("2").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        }
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponent() {
        componentView.componentEngine.component = Text("1").eraseToAnyComponent().reuseStrategy(.noReuse)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = VStack {
            Text("2").eraseToAnyComponent().reuseStrategy(.noReuse)
        }
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testReuseWithSameAttributes() {
        componentView.componentEngine.component = Text("1").backgroundColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.componentEngine.component = Text("2").backgroundColor(.blue)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWithDifferentAttributes() {
        componentView.componentEngine.component = Text("1").textColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.componentEngine.component = Text("2")
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithDifferentAttributesAndAnyComponentOfView() {
        componentView.componentEngine.component = Text("1").textColor(.red).eraseToAnyComponentOfView()
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.componentEngine.component = Text("2").eraseToAnyComponentOfView()
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithSameAttributes() {
        componentView.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red).id("1")
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red).id("2")
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
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
        componentView.componentEngine.component = ViewComponent(view: label1).textColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        XCTAssertEqual(existingLabel, label1)
        componentView.componentEngine.component = ViewComponent(view: label2).textColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")
        XCTAssertEqual(newLabel?.textColor, .red)
        XCTAssertEqual(newLabel, label2)
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testStructureIdentity() {
        componentView.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red)
        componentView.componentEngine.reloadData()
        XCTAssertEqual(componentView.componentEngine.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // Although the UILabels are using no reuse, they have the same structure identity, so they should be the same instance
        XCTAssertEqual(existingLabel, newLabel)
    }
}
