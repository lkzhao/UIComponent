import XCTest
@testable import UIComponent

final class TappableViewTests: XCTestCase {
    @available(iOS 13.4, *)
    func testDetachedViewDoesNotCreatePointerStyle() {
        let view = TappableView()
        let interaction = UIPointerInteraction(delegate: view)
        let region = UIPointerRegion(rect: view.bounds)

        XCTAssertNil(view.pointerInteraction(interaction, styleFor: region))
    }
}
