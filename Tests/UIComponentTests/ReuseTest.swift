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
  
  func testBasicReuseAndExtraValueReset() {
    componentView.component = Text("1").textAlignment(.center).textColor(.red).backgroundColor(.black)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    componentView.component = Text("2").backgroundColor(.black)
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")
    
    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
    XCTAssertNotEqual(newLabel?.textColor, .red)
    XCTAssertNotEqual(newLabel?.textAlignment, .center)
    XCTAssertEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 1)
    
    componentView.component = Text("3").textAlignment(.center).textColor(.red).backgroundColor(.black)
    componentView.reloadData()
    // the UILabel's values should be updated
    XCTAssertEqual(newLabel?.text, "3")
    XCTAssertEqual(newLabel?.textColor, .red)
    XCTAssertEqual(newLabel?.textAlignment, .center)
    XCTAssertEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 3)
    
    componentView.component = Text("4")
    componentView.reloadData()
    
    // the UILabel's values should be updated
    XCTAssertEqual(newLabel?.text, "4")
    XCTAssertNotEqual(newLabel?.textColor, .red)
    XCTAssertNotEqual(newLabel?.textAlignment, .center)
    XCTAssertNotEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 0)
  }

  func testNoReuseWhenReuseKeyDiffers() {
    componentView.component = ClosureViewComponent(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
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
    componentView.component = ClosureViewComponent(reuseKey: nil, update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    componentView.component = ClosureViewComponent(reuseKey: nil, update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should not be reused
    XCTAssertNotEqual(existingLabel, newLabel)
  }

  func testReuseWithClosureViewComponent() {
    componentView.component = ClosureViewComponent(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    componentView.component = ClosureViewComponent(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
  }

  func testReuseWithClosureViewComponentButExtraValueWontReset() {
    componentView.component = ClosureViewComponent(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
      label.textColor = .red
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let existingLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    XCTAssertEqual(existingLabel?.textColor, .red)
    componentView.component = ClosureViewComponent(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    componentView.reloadData()
    XCTAssertEqual(componentView.subviews.count, 1)
    let newLabel = componentView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
    
    // the textColor didn't reset
    XCTAssertEqual(newLabel?.textColor, .red)
  }
}

