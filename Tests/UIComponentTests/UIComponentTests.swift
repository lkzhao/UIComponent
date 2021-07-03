import XCTest
@testable import UIComponent

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
}
