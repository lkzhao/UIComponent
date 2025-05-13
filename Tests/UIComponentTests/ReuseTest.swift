//  Created by Luke Zhao on 2/15/20.

import Testing
@testable import UIComponent
import UIKit

@Suite("Reuse Tests")
@MainActor
struct ReuseTests {
    @Test func testBasicReuse() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

        view.componentEngine.component = Text("1").reuseKey("myLabel")
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2").reuseKey("myLabel")
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should be reused
        #expect(existingLabel == newLabel)
    }

    @Test func testStructureIdentity() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

        view.componentEngine.component = Text("1").textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseKey == nil)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2").textColor(.red)
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseKey == nil)
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // Although the UILabels are using no reuse, they have the same structure identity, so they should be the same instance
        #expect(existingLabel == newLabel)
    }

    @Test func testNoReuseWhenReuseKeyDiffers() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

        view.componentEngine.component = Text("1").reuseKey("myLabel")
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

    @Test func testNoReuseWhenNoReuseKey() throws {
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

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }

    @Test func testReuseWithWithDifferentAttributes() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

        view.componentEngine.component = Text("1").reuseKey("myLabel").backgroundColor(.red)
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        view.componentEngine.component = VStack {
            Text("2").backgroundColor(.blue).font(.boldSystemFont(ofSize: 20)).reuseKey("myLabel")
        }
        view.componentEngine.reloadData()
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should be reused
        #expect(existingLabel == newLabel)
    }

    @Test func testNoReuseWithSameAttributes() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

        view.componentEngine.component = Text("1").textColor(.red).id("1")
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseKey == nil)
        #expect(view.subviews.count == 1)
        let existingLabel = view.subviews.first as? UILabel
        #expect(existingLabel != nil)
        #expect(existingLabel?.text == "1")
        #expect(existingLabel?.textColor == .red)
        view.componentEngine.component = Text("2").textColor(.red).id("2")
        view.componentEngine.reloadData()
        #expect(view.componentEngine.renderNode?.reuseKey == nil)
        #expect(view.subviews.count == 1)
        let newLabel = view.subviews.first as? UILabel
        #expect(newLabel != nil)
        #expect(newLabel?.text == "2")

        // the UILabel should not be reused
        #expect(existingLabel != newLabel)
    }
}
