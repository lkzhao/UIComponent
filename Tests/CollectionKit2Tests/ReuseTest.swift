//
//  ReuseTest.swift
//  
//
//  Created by Luke Zhao on 2/15/20.
//
import XCTest
@testable import CollectionKit2

final class ReuseTests: XCTestCase {
  var collectionView: CollectionView!
  override func setUp() {
    collectionView = CollectionView()
    collectionView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testBasicReuse() {
    collectionView.provider = Text("1")
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    collectionView.provider = Text("2")
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")
    
    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
  }
  
  func testBasicReuseAndExtraValueReset() {
    collectionView.provider = Text("1").textAlignment(.center).color(.red).backgroundColor(.black)
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    collectionView.provider = Text("2").backgroundColor(.black)
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")
    
    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
    XCTAssertNotEqual(newLabel?.textColor, .red)
    XCTAssertNotEqual(newLabel?.textAlignment, .center)
    XCTAssertEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 1)
    
    collectionView.provider = Text("3").textAlignment(.center).color(.red).backgroundColor(.black)
    collectionView.reloadData()
    // the UILabel's values should be updated
    XCTAssertEqual(newLabel?.text, "3")
    XCTAssertEqual(newLabel?.textColor, .red)
    XCTAssertEqual(newLabel?.textAlignment, .center)
    XCTAssertEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 3)
    
    collectionView.provider = Text("4")
    collectionView.reloadData()
    
    // the UILabel's values should be updated
    XCTAssertEqual(newLabel?.text, "4")
    XCTAssertNotEqual(newLabel?.textColor, .red)
    XCTAssertNotEqual(newLabel?.textAlignment, .center)
    XCTAssertNotEqual(newLabel?.backgroundColor, .black)
    XCTAssertEqual(newLabel?.ckContext.valueResets.count, 0)
  }

  func testNoReuseWhenReuseKeyDiffers() {
    collectionView.provider = ClosureViewProvider(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    collectionView.provider = Text("2")
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should not be reused
    XCTAssertNotEqual(existingLabel, newLabel)
  }

  func testNoReuseWhenNoReuseKey() {
    collectionView.provider = ClosureViewProvider(reuseKey: nil, update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    collectionView.provider = ClosureViewProvider(reuseKey: nil, update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should not be reused
    XCTAssertNotEqual(existingLabel, newLabel)
  }

  func testReuseWithClosureViewProvider() {
    collectionView.provider = ClosureViewProvider(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    collectionView.provider = ClosureViewProvider(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
  }

  func testReuseWithClosureViewProviderButExtraValueWontReset() {
    collectionView.provider = ClosureViewProvider(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "1"
      label.textColor = .red
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let existingLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(existingLabel)
    XCTAssertEqual(existingLabel?.text, "1")
    XCTAssertEqual(existingLabel?.textColor, .red)
    collectionView.provider = ClosureViewProvider(reuseKey: "myLabel", update: { (label: UILabel) in
      label.text = "2"
    }, size: { _ in
      return CGSize(width: 50, height: 50)
    })
    collectionView.reloadData()
    XCTAssertEqual(collectionView.subviews.count, 1)
    let newLabel = collectionView.subviews.first as? UILabel
    XCTAssertNotNil(newLabel)
    XCTAssertEqual(newLabel?.text, "2")

    // the UILabel should be reused
    XCTAssertEqual(existingLabel, newLabel)
    
    // the textColor didn't reset
    XCTAssertEqual(newLabel?.textColor, .red)
  }
}

