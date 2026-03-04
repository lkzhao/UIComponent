import XCTest
@testable import UIComponent

final class RenderModeMutationBenchmarkTests: XCTestCase {
    private let viewportSize = CGSize(width: 320, height: 640)
    private let rowHeight: CGFloat = 1
    private let initialRowCount = 2_000
    private let mutationCount = 120
    private let minimumRowCount = 500
    private let randomSeed: UInt64 = 0xC0FFEE

    func testPerfRandomInsertRemove_NewRenderingMode() {
        runMutationBenchmark(useLegacyRenderingMode: false)
    }

    func testPerfRandomInsertRemove_LegacyRenderingMode() {
        runMutationBenchmark(useLegacyRenderingMode: true)
    }

    private func runMutationBenchmark(useLegacyRenderingMode: Bool) {
        let view = UIView(frame: CGRect(origin: .zero, size: viewportSize))
        view.componentEngine.useLegacyRenderingMode = useLegacyRenderingMode

        let idStates = makeRandomIDStates()
        let renderNodes = prepareRenderNodes(from: idStates, hostingView: view)

        guard let firstRenderNode = renderNodes.first else {
            XCTFail("Expected at least one prepared render node")
            return
        }

        let placeholderComponent = Space(height: rowHeight)

        // Warm up with the initial state outside measure.
        view.componentEngine.reloadWithExisting(component: placeholderComponent, renderNode: firstRenderNode)
        view.componentEngine.reloadData()

        let options = XCTMeasureOptions.default
        options.iterationCount = 12
        measure(metrics: [XCTClockMetric()], options: options) {
            for renderNode in renderNodes.dropFirst() {
                view.componentEngine.reloadWithExisting(component: placeholderComponent, renderNode: renderNode)
                view.componentEngine.reloadData()
            }
        }
    }

    private func prepareRenderNodes(from idStates: [[Int]], hostingView: UIView) -> [any RenderNode] {
        var renderNodes = [any RenderNode]()
        renderNodes.reserveCapacity(idStates.count)

        for ids in idStates {
            let component = makeComponent(ids: ids)
            let renderNode = EnvironmentValues.with(values: .init(\.hostingView, value: hostingView)) {
                component.layout(Constraint(maxSize: viewportSize))
            }
            renderNodes.append(renderNode)
        }

        return renderNodes
    }

    private func makeRandomIDStates() -> [[Int]] {
        var rng = LCG(state: randomSeed)
        var ids = Array(0..<initialRowCount)
        var nextID = initialRowCount

        var states = [[Int]]()
        states.reserveCapacity(mutationCount + 1)
        states.append(ids)

        for _ in 0..<mutationCount {
            let canRemove = ids.count > minimumRowCount
            let shouldInsert = !canRemove || rng.nextBool()

            if shouldInsert {
                let index = rng.nextInt(upperBound: ids.count + 1)
                ids.insert(nextID, at: index)
                nextID += 1
            } else {
                let index = rng.nextInt(upperBound: ids.count)
                ids.remove(at: index)
            }

            states.append(ids)
        }

        return states
    }

    private func makeComponent(ids: [Int]) -> any Component {
        VStack(spacing: 0) {
            for id in ids {
                Space(height: rowHeight)
                    .view()
                    .id("cell-\(id)")
            }
        }
    }

    private struct LCG {
        var state: UInt64

        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1442695040888963407
            return state
        }

        mutating func nextBool() -> Bool {
            (next() & 1) == 0
        }

        mutating func nextInt(upperBound: Int) -> Int {
            precondition(upperBound > 0, "upperBound must be greater than zero")
            return Int(next() % UInt64(upperBound))
        }
    }
}
