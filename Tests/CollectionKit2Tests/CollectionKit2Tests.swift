import XCTest
@testable import CollectionKit2

final class CollectionKit2Tests: XCTestCase {
	func testPerfHStackText() {
    let collectionView = CollectionView()
    measure {
      collectionView.provider = HStack {
        ForEach(0..<10000) { _ in
          Text("Test")
        }
      }
      collectionView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 600))
      collectionView.layoutIfNeeded()
    }
	}
}
