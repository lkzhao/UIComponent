//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent

final class ReuseTests: XCTestCase {
    var componentView: ComponentView!
    override func setUp() {
        componentView = ComponentView()
        componentView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicReuse() {
        componentView.component = Text("1")
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = VStack {
            Text("2")
        }
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenReuseStrategyDiffers() {
        componentView.component = Text("1").reuseStrategy(.key("myLabel"))
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = Text("2")
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategy() {
        componentView.component = Text("1").reuseStrategy(.noReuse)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = VStack {
            Text("2").reuseStrategy(.noReuse)
        }
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponentOfView() {
        componentView.component = Text("1").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = VStack {
            Text("2").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        }
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWhenNoReuseStrategyWithAnyComponent() {
        componentView.component = Text("1").eraseToAnyComponent().reuseStrategy(.noReuse)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = VStack {
            Text("2").eraseToAnyComponent().reuseStrategy(.noReuse)
        }
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testReuseWithSameAttributes() {
        componentView.component = Text("1").backgroundColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        componentView.component = Text("2").backgroundColor(.blue)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should be reused
        XCTAssertEqual(existingLabel, newLabel)
    }

    func testNoReuseWithDifferentAttributes() {
        componentView.component = Text("1").textColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.component = Text("2")
        componentView.reloadData()
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // the UILabel should not be reused
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testNoReuseWithSameAttributes() {
        componentView.component = Text("1").reuseStrategy(.noReuse).textColor(.red).id("1")
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.component = Text("2").reuseStrategy(.noReuse).textColor(.red).id("2")
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
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
        componentView.component = ViewComponent(view: label1).textColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        XCTAssertEqual(existingLabel, label1)
        componentView.component = ViewComponent(view: label2).textColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")
        XCTAssertEqual(newLabel?.textColor, .red)
        XCTAssertEqual(newLabel, label2)
        XCTAssertNotEqual(existingLabel, newLabel)
    }

    func testStructureIdentity() {
        componentView.component = Text("1").reuseStrategy(.noReuse).textColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let existingLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(existingLabel)
        XCTAssertEqual(existingLabel?.text, "1")
        XCTAssertEqual(existingLabel?.textColor, .red)
        componentView.component = Text("2").reuseStrategy(.noReuse).textColor(.red)
        componentView.reloadData()
        XCTAssertEqual(componentView.renderNode?.reuseStrategy, .noReuse)
        XCTAssertEqual(componentView.subviews.count, 1)
        let newLabel = componentView.subviews.first as? UILabel
        XCTAssertNotNil(newLabel)
        XCTAssertEqual(newLabel?.text, "2")

        // Although the UILabels are using no reuse, they have the same structure identity, so they should be the same instance
        XCTAssertEqual(existingLabel, newLabel)
    }
}
