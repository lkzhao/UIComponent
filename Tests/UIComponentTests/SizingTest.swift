//
//  SizingTest.swift
//  UIComponent
//
//  Created by Luke Zhao on 11/8/24.
//

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
}
