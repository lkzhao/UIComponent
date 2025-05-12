//  Created by Luke Zhao on 2/15/20.

import Testing
@testable import UIComponent
import UIKit

@Suite("Reuse Tests")
@MainActor
struct ReuseTests {
    @Test func testBasicReuse() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1")
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2")
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should be reused
        #expect(existingLabel == newLabel)
    }

    @Test func testNoReuseWhenReuseStrategyDiffers() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").reuseStrategy(.key("myLabel"))
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = Text("2")
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWhenNoReuseStrategy() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2").reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWhenNoReuseStrategyWithAnyComponentOfView() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2").eraseToAnyComponentOfView().reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWhenNoReuseStrategyWithAnyComponent() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").eraseToAnyComponent().reuseStrategy(.noReuse)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2").eraseToAnyComponent().reuseStrategy(.noReuse)
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testReuseWithSameAttributes() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").backgroundColor(.red)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = Text("2").backgroundColor(.blue)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should be reused
        #expect(existingLabel == newLabel)
    }

    @Test func testNoReuseWithDifferentAttributes() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2")
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWithDifferentAttributesAndAnyComponentOfView() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").textColor(.red).eraseToAnyComponentOfView()
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2").eraseToAnyComponentOfView()
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWithSameAttributes() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red).id("1")
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red).id("2")
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testNoReuseWithViewComponent() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        let label1 = UILabel()
        label1.text = "1"
        let label2 = UILabel()
        label2.text = "2"
        view.componentEngine.component = ViewComponent(view: label1).textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        #expect(existingLabel == label1)
        view.componentEngine.component = ViewComponent(view: label2).textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")
        #expect(newLabel?.textColor == .red)
        #expect(newLabel == label2)
        #expect(existingLabel != newLabel)
    }

    @Test func testStructureIdentity() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        
        view.componentEngine.component = Text("1").reuseStrategy(.noReuse).textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2").reuseStrategy(.noReuse).textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseStrategy == .noReuse)
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // Although the UILabels are using no reuse, they have the same structure identity, so they should be the same instance
        #expect(existingLabel == newLabel)
    }
}
