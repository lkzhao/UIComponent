//  Created by Luke Zhao on 4/24/25.

import XCTest

@testable import UIComponent

final class LazyLayoutTests: XCTestCase {
   /// Test to make sure component with fixed size are
   /// not being layouted when not visible
   func testLazyLayout() {
       let view = UIView()
       view.componentEngine.component = VStack {
           Text(text1).lazy(width: 300, height: 600)
           Text(text2).lazy(width: 300, height: 600)
       }
       view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
       view.layoutIfNeeded()
       let vRenderNode = view.componentEngine.renderNode as? VerticalRenderNode
       XCTAssertNotNil(vRenderNode)
       let firstText = vRenderNode!.children[0] as? LazyRenderNode<Text>
       let secondText = vRenderNode!.children[1] as? LazyRenderNode<Text>
       XCTAssertNotNil(firstText)
       XCTAssertNotNil(secondText)
       XCTAssertEqual(view.componentEngine.visibleRenderables.count, 1)
       XCTAssertEqual(firstText!.didLayout, true)
       XCTAssertEqual(secondText!.didLayout, false)
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
           }.lazy(width: 300, height: 600)
           ConstraintReader { _ in
               text2HostingView = Environment(\.hostingView).wrappedValue
               return Text(text2)
           }.lazy(width: 300, height: 600)
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
           }.lazy(width: 300, height: 600)
           Text(text2).lazy(width: 300, height: 600)
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
                   Text(text1).lazy {
                       .init(width: $0.maxSize.width, height: 50)
                   }
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
}
