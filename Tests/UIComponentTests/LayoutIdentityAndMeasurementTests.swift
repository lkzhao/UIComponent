//  Created by Luke Zhao on 2/12/26.

import Foundation
import Testing
@testable import UIComponent

@Suite("Layout Identity And Deferred Measurement")
@MainActor
struct LayoutIdentityAndMeasurementTests {
    @Test func testLayoutIdentityContextScopesAndStateRestore() throws {
        let identities = LayoutIdentityContext.beginLayoutPass {
            let firstAuto = LayoutIdentityContext.makeIdentity()
            let explicit = LayoutIdentityContext.withExplicitID("cell-42") {
                [
                    LayoutIdentityContext.makeIdentity(),
                    LayoutIdentityContext.makeIdentity(),
                ]
            }
            let secondAuto = LayoutIdentityContext.makeIdentity()
            return [firstAuto] + explicit + [secondAuto]
        }

        #expect(identities == ["auto:1", "id:cell-42", "id:cell-42#2", "auto:2"])

        let snapshot = LayoutIdentityContext.beginLayoutPass {
            _ = LayoutIdentityContext.makeIdentity()
            return LayoutIdentityContext.currentState
        }

        let resumedIdentity = LayoutIdentityContext.beginLayoutPass {
            LayoutIdentityContext.withState(state: snapshot) {
                LayoutIdentityContext.makeIdentity()
            }
        }

        #expect(resumedIdentity == "auto:2")
    }

    @Test func testLayoutIdentityContextNestedExplicitScopes() throws {
        let identities = LayoutIdentityContext.beginLayoutPass {
            LayoutIdentityContext.withExplicitID("outer") {
                let firstOuter = LayoutIdentityContext.makeIdentity()
                let inner = LayoutIdentityContext.withExplicitID("inner") {
                    [
                        LayoutIdentityContext.makeIdentity(),
                        LayoutIdentityContext.makeIdentity(),
                    ]
                }
                let secondOuter = LayoutIdentityContext.makeIdentity()
                return [firstOuter] + inner + [secondOuter]
            }
        }

        #expect(identities == ["id:outer", "id:inner", "id:inner#2", "id:outer#2"])
    }

    @Test func testViewComponentDeferredMeasurementUsesCacheOnSecondReload() throws {
        TrailingProbeView.reportedSize = CGSize(width: 87, height: 31)
        TrailingProbeView.sizeThatFitsCallCount = 0

        let host = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        host.componentEngine.component = ViewComponent(generator: TrailingProbeView())
        host.componentEngine.reloadData()

        #expect(host.componentEngine.renderNode?.size == .zero)
        #expect(TrailingProbeView.sizeThatFitsCallCount == 1)

        drainMainQueue()
        host.componentEngine.reloadData()

        #expect(host.componentEngine.renderNode?.size == CGSize(width: 87, height: 31))
        #expect(TrailingProbeView.sizeThatFitsCallCount >= 2)
    }

    @Test func testViewComponentExplicitIDKeepsMeasurementAcrossStructuralDrift() throws {
        TrailingProbeView.reportedSize = CGSize(width: 110, height: 44)
        TrailingProbeView.sizeThatFitsCallCount = 0

        let host = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        host.componentEngine.component = componentWithMeasuredTrailingView(includeLeadingView: false, useExplicitID: true)
        host.componentEngine.reloadData()
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(.zero))

        drainMainQueue()
        host.componentEngine.reloadData()
        let measuredSize = CGSize(width: 110, height: 44)
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(measuredSize))

        host.componentEngine.component = componentWithMeasuredTrailingView(includeLeadingView: true, useExplicitID: true)
        host.componentEngine.reloadData()
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(measuredSize))
    }

    @Test func testViewComponentWithoutIDFallsBackToZeroAfterStructuralDrift() throws {
        TrailingProbeView.reportedSize = CGSize(width: 120, height: 50)
        TrailingProbeView.sizeThatFitsCallCount = 0

        let host = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        host.componentEngine.component = componentWithMeasuredTrailingView(includeLeadingView: false, useExplicitID: false)
        host.componentEngine.reloadData()
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(.zero))

        drainMainQueue()
        host.componentEngine.reloadData()
        let measuredSize = CGSize(width: 120, height: 50)
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(measuredSize))

        host.componentEngine.component = componentWithMeasuredTrailingView(includeLeadingView: true, useExplicitID: false)
        host.componentEngine.reloadData()
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(.zero))

        drainMainQueue()
        host.componentEngine.reloadData()
        #expect(lastChildSize(from: host.componentEngine.renderNode) == .some(measuredSize))
    }

    @Test func testViewComponentMeasurementCacheRespectsConstraintChanges() throws {
        ConstraintProbeView.sizeThatFitsCallCount = 0

        let host = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        host.componentEngine.component = ViewComponent(generator: ConstraintProbeView())
        host.componentEngine.reloadData()
        #expect(host.componentEngine.renderNode?.size == .zero)
        drainMainQueue()
        host.componentEngine.reloadData()
        #expect(host.componentEngine.renderNode?.size == CGSize(width: 200, height: 17))

        host.bounds.size.width = 90
        host.componentEngine.reloadData()
        #expect(host.componentEngine.renderNode?.size == .zero)
        drainMainQueue()
        host.componentEngine.reloadData()
        #expect(host.componentEngine.renderNode?.size == CGSize(width: 90, height: 17))
        #expect(ConstraintProbeView.sizeThatFitsCallCount >= 2)
    }

    @Test func testViewComponentDuplicateExplicitIDScopeSeparatesSiblingMeasurements() throws {
        FirstSiblingProbeView.sizeThatFitsCallCount = 0
        SecondSiblingProbeView.sizeThatFitsCallCount = 0

        let host = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        host.componentEngine.component = AnyComponent(
            content: AlwaysRenderContainer(
                children: [
                    ViewComponent(generator: FirstSiblingProbeView()).id("same-id"),
                    ViewComponent(generator: SecondSiblingProbeView()).id("same-id"),
                ]
            )
        )

        host.componentEngine.reloadData()
        #expect(childSizes(from: host.componentEngine.renderNode) == [CGSize.zero, CGSize.zero])
        drainMainQueue()
        host.componentEngine.reloadData()
        #expect(childSizes(from: host.componentEngine.renderNode) == [CGSize(width: 44, height: 10), CGSize(width: 88, height: 20)])
    }

    private func componentWithMeasuredTrailingView(includeLeadingView: Bool, useExplicitID: Bool) -> AnyComponent {
        let trailing: any Component
        if useExplicitID {
            trailing = ViewComponent(generator: TrailingProbeView()).id("stable-trailing")
        } else {
            trailing = ViewComponent(generator: TrailingProbeView())
        }

        if includeLeadingView {
            return AnyComponent(
                content: AlwaysRenderContainer(
                    children: [
                        ViewComponent(generator: LeadingProbeView()),
                        trailing,
                    ]
                )
            )
        } else {
            return AnyComponent(
                content: AlwaysRenderContainer(
                    children: [trailing]
                )
            )
        }
    }

    private func lastChildSize(from renderNode: (any RenderNode)?) -> CGSize? {
        renderNode?.children.last?.size
    }

    private func childSizes(from renderNode: (any RenderNode)?) -> [CGSize] {
        renderNode?.children.map(\.size) ?? []
    }

    private func drainMainQueue() {
        for _ in 0..<5 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
    }
}

private final class LeadingProbeView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: 12, height: 12)
    }
}

private final class TrailingProbeView: UIView {
    static var reportedSize = CGSize(width: 100, height: 40)
    static var sizeThatFitsCallCount = 0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.sizeThatFitsCallCount += 1
        return Self.reportedSize
    }
}

private final class ConstraintProbeView: UIView {
    static var sizeThatFitsCallCount = 0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.sizeThatFitsCallCount += 1
        return CGSize(width: size.width, height: 17)
    }
}

private final class FirstSiblingProbeView: UIView {
    static var sizeThatFitsCallCount = 0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.sizeThatFitsCallCount += 1
        return CGSize(width: 44, height: 10)
    }
}

private final class SecondSiblingProbeView: UIView {
    static var sizeThatFitsCallCount = 0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.sizeThatFitsCallCount += 1
        return CGSize(width: 88, height: 20)
    }
}

private struct AlwaysRenderContainer: Component {
    let children: [any Component]

    func layout(_ constraint: Constraint) -> AlwaysRenderNode {
        let renderNodes = children.map {
            $0.layout(constraint)
        }
        let size = renderNodes.reduce(CGSize.zero) { partialResult, renderNode in
            CGSize(
                width: max(partialResult.width, renderNode.size.width),
                height: max(partialResult.height, renderNode.size.height)
            )
        }.bound(to: constraint)
        return AlwaysRenderNode(
            size: size,
            children: renderNodes,
            positions: .init(repeating: .zero, count: renderNodes.count)
        )
    }
}
