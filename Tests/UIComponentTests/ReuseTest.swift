//
//  ReuseTest.swift
//  
//
//  Created by Luke Zhao on 2/15/20.
//
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
    componentView.component = Text("2")
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")
    
    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
  }

  func testNoReuseWhenReuseKeyDiffers() {
    componentView.component = Text("1").reuseKey("myLabel")
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

  func testNoReuseWhenNoReuseKey() {
    componentView.component = Text("1").reuseKey(nil)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    componentView.component = Text("2").reuseKey(nil)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should not be reused
    XCTAssertNotEqual(existingLabel, newLabel)
  }

  func testReuseWithSimpleViewComponent() {
    componentView.component = SimpleViewComponent<UILabel>().text("1").backgroundColor(.red)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    componentView.component = SimpleViewComponent<UILabel>().text("2").backgroundColor(.blue)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
  }

  func testNoReuseWithSimpleViewComponentWithDifferentAttributes() {
    componentView.component = SimpleViewComponent<UILabel>().text("1").textColor(.red)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    XCTAssertEqual(existingLabel?.textColor, .red)
    componentView.component = SimpleViewComponent<UILabel>().text("2")
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should not be reused
    XCTAssertNotEqual(existingLabel, newLabel)
  }
}

