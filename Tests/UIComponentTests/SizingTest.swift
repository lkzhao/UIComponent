//  Created by Luke Zhao on 11/8/24.

import Testing
@testable import UIComponent

public struct AspectSpace: Component {
    let size: CGSize

    public init(width: CGFloat = 0, height: CGFloat = 0) {
        size = CGSize(width: width, height: height)
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        SpaceRenderNode(size: size.boundWithAspectRatio(to: constraint))
    }
}

@Suite("Sizing")
@MainActor
struct SizingTest {

    @Test func testAspectRatioSizing() throws {
        let base = AspectSpace(width: 100, height: 100)
        #expect(base.layout(Constraint(maxSize: CGSize(width: 200.0, height: .infinity))).size == CGSize(width: 100, height: 100))
        #expect(base.layout(Constraint(maxSize: CGSize(width: 50.0, height: .infinity))).size == CGSize(width: 50, height: 50))
        #expect(base.layout(Constraint(maxSize: CGSize(width: 50.0, height: 40.0))).size == CGSize(width: 40, height: 40))

        #expect(base.size(width: .fill).layout(Constraint(maxSize: CGSize(width: 200.0, height: .infinity))).size == CGSize(width: 200, height: 200))
        #expect(base.size(width: .fill).layout(Constraint(maxSize: CGSize(width: 50.0, height: .infinity))).size == CGSize(width: 50, height: 50))
    }

    @Test func testFlexShrinkSizing() throws {
        let component = HStack {
            Text("This is a long text that test flex shrink sizing").flexShrink(1)
        }
        #expect(component.layout(Constraint(maxSize: CGSize(width: 100.0, height: .infinity))).size.width < 100)
    }
    
    @Test func testFlexShrinkInFlowSizing() throws {
        let component = Flow {
            HStack {
                Text("This is a short text")
            }.size(width: .fill)
        }
        #expect(component.layout(Constraint(maxSize: CGSize(width: 1000.0, height: .infinity))).size.width == 1000)
        #expect(component.layout(Constraint(maxSize: CGSize(width: 1000.0, height: .infinity))).children.first!.size.width == 1000)
    }

    @Test func testWaterfallSeparateSpacing() throws {
        let component = Waterfall(columns: 2, columnSpacing: 10, interItemSpacing: 5) {
            Space(width: 10, height: 20)
            Space(width: 10, height: 10)
            Space(width: 10, height: 15)
        }

        let renderNode = component.layout(Constraint(maxSize: CGSize(width: 110, height: CGFloat.infinity)))
        #expect(renderNode.size == CGSize(width: 110, height: 30))
        #expect(renderNode.children.map { $0.size } == [
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 10),
            CGSize(width: 50, height: 15)
        ])
        #expect(renderNode.positions == [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 60, y: 0),
            CGPoint(x: 60, y: 15)
        ])
    }

    @Test func testHorizontalWaterfallSeparateSpacing() throws {
        let component = HorizontalWaterfall(columns: 2, columnSpacing: 10, interItemSpacing: 5) {
            Space(width: 20, height: 10)
            Space(width: 10, height: 10)
            Space(width: 15, height: 10)
        }

        let renderNode = component.layout(Constraint(maxSize: CGSize(width: CGFloat.infinity, height: 110)))
        #expect(renderNode.size == CGSize(width: 30, height: 110))
        #expect(renderNode.children.map { $0.size } == [
            CGSize(width: 20, height: 50),
            CGSize(width: 10, height: 50),
            CGSize(width: 15, height: 50)
        ])
        #expect(renderNode.positions == [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 60),
            CGPoint(x: 15, y: 60)
        ])
    }
}
