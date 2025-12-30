//  Created by Luke Zhao on 4/24/25.

import Testing
@testable import UIComponent

@Suite("Lazy Layout")
@MainActor
struct LazyLayoutTests {
    /// Test to make sure component with fixed size are
    /// not being layouted when not visible
    @Test func testLazyLayout() throws {
        let view = UIView()
        view.componentEngine.component = VStack {
            Text(text1).lazy(width: 300, height: 600)
            Text(text2).lazy(width: 300, height: 600)
        }
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
        view.layoutIfNeeded()
        let vRenderNode = view.componentEngine.renderNode as? VerticalRenderNode
        #expect(vRenderNode != nil)
        let firstText = vRenderNode!.children[0] as? LazyRenderNode<Text>
        let secondText = vRenderNode!.children[1] as? LazyRenderNode<Text>
        #expect(firstText != nil)
        #expect(secondText != nil)
        #expect(view.componentEngine.visibleRenderables.count == 1)
        #expect(firstText!.didLayout == true)
        #expect(secondText!.didLayout == false)
    }

    /// Test to make sure environment is passed down to lazy layout even when layout is performed later
    @Test func testLazyLayoutEnvironment() throws {
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
        #expect(text1HostingView === view)
        #expect(text2HostingView == nil)
        view.bounds = CGRect(x: 0, y: 10, width: 300, height: 600)
        view.layoutIfNeeded()
        #expect(text1HostingView === view)
        #expect(text2HostingView === view)
    }

    /// Test to make sure weak environment value is correctly release even when captured by a lazy layout
    @Test func testLazyLayoutWeakEnvironment() throws {
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
        #expect(view2 != nil)
        #expect(text1HostingView != nil)
        #expect(text1HostingView === view)
        view = nil
        #expect(text1HostingView == nil)
        #expect(view2 == nil)
    }

    @Test func testLazyLayoutPerf() throws {
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
        #expect(fixedSizeLayoutTime * 2 < rawLayoutTime)
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
