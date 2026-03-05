import Testing
@testable import UIComponent

private final class GeneratedSizingView: UIView {
    static var measuredSize: CGSize = .zero
    static var sizeThatFitsCallCount = 0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Self.sizeThatFitsCallCount += 1
        return Self.measuredSize
    }
}

private final class ExistingSizingView: UIView {
    let measuredSize: CGSize

    init(measuredSize: CGSize) {
        self.measuredSize = measuredSize
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        measuredSize
    }
}

private struct BuilderWrappedSizingComponent: ComponentBuilder {
    func build() -> ViewComponent<GeneratedSizingView> {
        ViewComponent<GeneratedSizingView>()
    }
}

private struct DirectWrappedSizingComponent: Component {
    func layout(_ constraint: Constraint) -> ViewRenderNode<GeneratedSizingView> {
        ViewComponent<GeneratedSizingView>().layout(constraint)
    }
}

@Suite("Measure Size")
@MainActor
struct MeasureSizeTests {
    @Test func testMeasureSizeAppliesMeasuredSizeForGeneratedCustomView() throws {
        GeneratedSizingView.measuredSize = CGSize(width: 80, height: 30)
        GeneratedSizingView.sizeThatFitsCallCount = 0

        let hostingView = makeHostingView(size: CGSize(width: 200, height: 200))
        hostingView.componentEngine.component = ViewComponent<GeneratedSizingView>().measureSize(key: "generated")

        layoutTwice(hostingView)

        #expect(hostingView.componentEngine.measuredSizes["generated"] == CGSize(width: 80, height: 30))
        #expect(hostingView.componentEngine.renderNode?.size == CGSize(width: 80, height: 30))
        #expect(hostingView.componentEngine.reloadCount >= 2)
        #expect(GeneratedSizingView.sizeThatFitsCallCount >= 2)
    }

    @Test func testMeasureSizeStoresConstraintBoundedSize() throws {
        GeneratedSizingView.measuredSize = CGSize(width: 500, height: 100)
        GeneratedSizingView.sizeThatFitsCallCount = 0

        let expected = CGSize(width: 120, height: 40)
        let hostingView = makeHostingView(size: expected)
        hostingView.componentEngine.component = ViewComponent<GeneratedSizingView>().measureSize(key: "bounded")

        layoutTwice(hostingView)

        #expect(hostingView.componentEngine.measuredSizes["bounded"] == expected)
        #expect(hostingView.componentEngine.renderNode?.size == expected)
        #expect(GeneratedSizingView.sizeThatFitsCallCount >= 2)
    }

    @Test func testMeasureSizeWorksForCustomBuilderComponent() throws {
        GeneratedSizingView.measuredSize = CGSize(width: 91, height: 37)
        GeneratedSizingView.sizeThatFitsCallCount = 0

        let hostingView = makeHostingView(size: CGSize(width: 200, height: 200))
        hostingView.componentEngine.component = BuilderWrappedSizingComponent().measureSize(key: "builder")

        layoutTwice(hostingView)

        #expect(hostingView.componentEngine.measuredSizes["builder"] == CGSize(width: 91, height: 37))
        #expect(hostingView.componentEngine.renderNode?.size == CGSize(width: 91, height: 37))
        #expect(hostingView.componentEngine.reloadCount >= 2)
    }

    @Test func testMeasureSizeWorksForDirectCustomComponent() throws {
        GeneratedSizingView.measuredSize = CGSize(width: 64, height: 22)
        GeneratedSizingView.sizeThatFitsCallCount = 0

        let hostingView = makeHostingView(size: CGSize(width: 200, height: 200))
        hostingView.componentEngine.component = DirectWrappedSizingComponent().measureSize(key: "direct")

        layoutTwice(hostingView)

        #expect(hostingView.componentEngine.measuredSizes["direct"] == CGSize(width: 64, height: 22))
        #expect(hostingView.componentEngine.renderNode?.size == CGSize(width: 64, height: 22))
        #expect(hostingView.componentEngine.reloadCount >= 2)
    }

    @Test func testMeasureSizeDoesNotReloadWhenSizeAlreadyMatches() throws {
        let existingView = ExistingSizingView(measuredSize: CGSize(width: 55, height: 19))
        let hostingView = makeHostingView(size: CGSize(width: 200, height: 200))
        hostingView.componentEngine.component = ViewComponent(view: existingView).measureSize(key: "existing")

        hostingView.layoutIfNeeded()

        #expect(hostingView.componentEngine.measuredSizes["existing"] == nil)
        #expect(hostingView.componentEngine.reloadCount == 1)
        #expect(hostingView.componentEngine.renderNode?.size == CGSize(width: 55, height: 19))
    }

    private func makeHostingView(size: CGSize) -> UIView {
        UIView(frame: CGRect(origin: .zero, size: size))
    }

    private func layoutTwice(_ view: UIView) {
        view.layoutIfNeeded()
        view.layoutIfNeeded()
    }
}
