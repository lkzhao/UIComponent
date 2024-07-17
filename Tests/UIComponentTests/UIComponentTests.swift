//  Created by Luke Zhao on 2/15/20.

import XCTest

@testable import UIComponent

let text1 = "This is a test of layout methods"
let text2 = "This is a test of layout"
let font = UIFont.systemFont(ofSize: 16)
let maxSize = CGSize(width: 100, height: CGFloat.infinity)

final class UIComponentTests: XCTestCase {
    func testPerfHStackText() {
        let view = UIView()
        measure {
            view.componentEngine.component = HStack {
                for _ in 0..<10000 {
                    Text("Test")
                }
            }
            view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
            view.layoutIfNeeded()
        }
    }

    func testVisibleInsets() {
        let view = UIView()
        view.componentEngine.component = VStack(spacing: 100) {
            Text(text1).size(width: 300, height: 300)
            Text(text2).size(width: 300, height: 300)
        }.inset(100).visibleInset(-100)
        view.frame = CGRect(x: 0, y: 0, width: 500, height: 400)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)
        view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 2)
    }

    func testOffsetVisibility() {
        // Offset shouldn't adjust visibility, it should use the original frame for visibility testing
        let view = UIView()
        view.componentEngine.component = ZStack {
            Text(text1).size(width: 300, height: 300).offset(CGPoint(x: 0, y: 300))
        }
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)

        view.bounds = CGRect(x: 0, y: 300, width: 300, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 0)
    }

    /// Test to make sure component with fixed size are
    /// not being layouted when not visible
    func testLazyLayout() {
        let view = UIView()
        view.componentEngine.component = VStack {
            Text(text1).size(width: 300, height: 600)
            Text(text2).size(width: 300, height: 600)
        }
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.layoutIfNeeded()
        let vRenderNode = view.componentEngine.renderNode as? VerticalRenderNode
        XCTAssertNotNil(vRenderNode)
        let firstText = vRenderNode!.children[0] as? AnyRenderNodeOfView<UILabel>
        let secondText = vRenderNode!.children[1] as? AnyRenderNodeOfView<UILabel>
        XCTAssertNotNil(firstText)
        XCTAssertNotNil(secondText)
        XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)
        let lazyNode1 = firstText!.erasing as? LazyRenderNode<Text>
        let lazyNode2 = secondText!.erasing as? LazyRenderNode<Text>
        XCTAssertEqual(lazyNode1!.didLayout, true)
        XCTAssertEqual(lazyNode2!.didLayout, false)
    }
    /// Test to make sure environment is passed down to lazy layout even when layout is performed later
    func testLazyLayoutEnvironment() {
        let view = UIView()
        var text1HostingView: UIView?
        var text2HostingView: UIView?
        view.componentEngine.component = VStack {
            ConstraintReader { _ in
                text1HostingView = Environment(\.hostingView).wrappedValue
                return Text(text1)
            }.size(width: 300, height: 600)
            ConstraintReader { _ in
                text2HostingView = Environment(\.hostingView).wrappedValue
                return Text(text2)
            }.size(width: 300, height: 600)
        }
        view.bounds = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.layoutIfNeeded()
        XCTAssertIdentical(text1HostingView, view)
        XCTAssertNil(text2HostingView)
        view.bounds = CGRect(x: 0, y: 10, width: 300, height: 600)
        view.layoutIfNeeded()
        XCTAssertIdentical(text1HostingView, view)
        XCTAssertIdentical(text2HostingView, view)
    }
    /// Test to make sure weak environment value is correctly release even when captured by a lazy layout
    func testLazyLayoutWeakEnvironment() {
        var view: UIView? = UIView()
        weak var view2 = view
        weak var text1HostingView: UIView?
        view?.componentEngine.component = VStack {
            ConstraintReader { _ in
                text1HostingView = Environment(\.hostingView).wrappedValue
                return Text(text1)
            }.size(width: 300, height: 600)
            Text(text2).size(width: 300, height: 600)
        }
        view?.bounds = CGRect(x: 0, y: 0, width: 300, height: 600)
        view?.layoutIfNeeded()
        XCTAssertNotNil(view2)
        XCTAssertNotNil(text1HostingView)
        XCTAssertIdentical(text1HostingView, view)
        view = nil
        XCTAssertNil(text1HostingView)
        XCTAssertNil(view2)
    }
    func testLazyLayoutPerf() {
        let rawLayoutTime = measureTime {
            VStack {
                for _ in 0..<10000 {
                    Text(text1)
                }
            }
        }
        let fixedSizeLayoutTime = measureTime {
            VStack {
                for _ in 0..<10000 {
                    Text(text1).size(width: .fill, height: 50)
                }
            }
        }
        print("Layout 10000 text with fixed sized used \(fixedSizeLayoutTime)s.")
        print("Layout 10000 text with dynamic sized used \(rawLayoutTime)s.")
        XCTAssertLessThan(fixedSizeLayoutTime * 2, rawLayoutTime)
    }
    func measureTime(_ component: () -> any Component) -> TimeInterval {
        let view = UIView()
        let startTime = CACurrentMediaTime()
        view.componentEngine.component = component()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.layoutIfNeeded()
        return CACurrentMediaTime() - startTime
    }
    func testPerfTextLayout() {
        measure {
            for _ in 0..<1000 {
                let attrText = NSAttributedString(string: text1, attributes: [.font: font])
                _ = attrText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil).size
                let attrText2 = NSAttributedString(string: text2, attributes: [.font: font])
                _ = attrText2.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil).size
            }
        }
    }
    func testPerfUILabelLayout() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        measure {
            for _ in 0..<1000 {
                label.text = text1
                _ = label.sizeThatFits(maxSize)
                label.text = text2
                _ = label.sizeThatFits(maxSize)
            }
        }
    }
    func testPerfNewUILabelLayout() {
        measure {
            for _ in 0..<1000 {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 16)
                label.text = text1
                _ = label.sizeThatFits(maxSize)
                let label2 = UILabel()
                label2.font = UIFont.systemFont(ofSize: 16)
                label2.text = text2
                _ = label2.sizeThatFits(maxSize)
            }
        }
    }
}
