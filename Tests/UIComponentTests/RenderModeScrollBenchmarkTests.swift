import XCTest
@testable import UIComponent

final class RenderModeScrollBenchmarkTests: XCTestCase {
    private let rowCount = 10_000
    private let rowHeight: CGFloat = 1
    private let viewportSize = CGSize(width: 320, height: 640)

    func testPerfScrollLargeList_NewRenderingMode() {
        runScrollBenchmark(useLegacyRenderingMode: false)
    }

    func testPerfScrollLargeList_LegacyRenderingMode() {
        runScrollBenchmark(useLegacyRenderingMode: true)
    }

    private func runScrollBenchmark(useLegacyRenderingMode: Bool) {
        let view = UIView(frame: CGRect(origin: .zero, size: viewportSize))
        view.componentEngine.useLegacyRenderingMode = useLegacyRenderingMode
        view.componentEngine.component = makeLargeListComponent()

        // Initial layout is intentionally outside measure to focus on scroll-driven renders.
        view.layoutIfNeeded()

        let maxOffset = max(0, CGFloat(rowCount) * rowHeight - viewportSize.height)
        let offsets = makeScrollOffsets(maxOffset: maxOffset, step: 40, cycles: 3)

        let options = XCTMeasureOptions.default
        options.iterationCount = 20
        measure(metrics: [XCTClockMetric()], options: options) {
            for y in offsets {
                view.bounds.origin.y = y
                view.layoutIfNeeded()
            }
        }
    }

    private func makeLargeListComponent() -> any Component {
        VStack(spacing: 0) {
            for row in 0..<rowCount {
                Space(height: 1)
                    .view()
                    .id("row-\(row)")
            }
        }
    }

    private func makeScrollOffsets(maxOffset: CGFloat, step: CGFloat, cycles: Int) -> [CGFloat] {
        guard maxOffset > 0 else { return [0] }

        let clampedStep = max(1, step)
        let forward = stride(from: CGFloat(0), through: maxOffset, by: clampedStep).map { min($0, maxOffset) }

        var offsets = [CGFloat]()
        offsets.reserveCapacity(forward.count * max(1, cycles) * 2)

        for _ in 0..<cycles {
            offsets.append(contentsOf: forward)
            if forward.count > 2 {
                offsets.append(contentsOf: forward.dropFirst().dropLast().reversed())
            }
        }

        return offsets
    }
}
