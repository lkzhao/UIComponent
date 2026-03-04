import Testing
@testable import UIComponent

@Suite("View Diff Tests")
@MainActor
struct ViewDiffTests {
    private final class DeferredDeleteStore {
        var completions: [() -> Void] = []
    }

    @Test func testDiffActions() {
        let result = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c", "d"],
            newIDs: ["a", "x", "c", "y"]
        )

        let expectedDeleteActions: [IDDiffHelper.DeleteAction] = [
            .init(oldIndex: 1),
            .init(oldIndex: 3)
        ]
        #expect(result.deleteActions == expectedDeleteActions)
        #expect(result.moveActions.isEmpty)

        let expectedRenderActions: [IDDiffHelper.RenderAction] = [
            .init(newIndex: 0, kind: .keep(oldIndex: 0)),
            .init(newIndex: 1, kind: .insert(insertBeforeOldIndex: 2)),
            .init(newIndex: 2, kind: .keep(oldIndex: 2)),
            .init(newIndex: 3, kind: .insert(insertBeforeOldIndex: nil))
        ]
        #expect(result.renderActions == expectedRenderActions)
        #expect(result.unchangedOrderCount == nil)
    }

    @Test func testDiffUnchangedOrderFastPath() {
        let result = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c"],
            newIDs: ["a", "b", "c"]
        )
        #expect(result.deleteActions.isEmpty)
        #expect(result.moveActions.isEmpty)
        #expect(result.renderActions.isEmpty)
        #expect(result.unchangedOrderCount == 3)
    }

    @Test func testDiffMoveActions() {
        let result = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c"],
            newIDs: ["c", "a", "b"]
        )
        #expect(result.deleteActions.isEmpty)
        #expect(result.moveActions == [
            .init(oldIndex: 2, insertBeforeOldIndex: 0)
        ])
    }

    @Test func testInsertBeforeNextExistingKeepsDeletingViewOrder() {
        let deleteStore = DeferredDeleteStore()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))

        view.componentEngine.component = VStack(spacing: 0) {
            Text("A").id("A").size(width: .fill, height: 20)
            Text("B").id("B").size(width: .fill, height: 20).animateDelete { _, _, completion in
                deleteStore.completions.append(completion)
            }
            Text("C").id("C").size(width: .fill, height: 20)
        }
        view.componentEngine.reloadData()
        #expect(labelTexts(in: view) == ["A", "B", "C"])

        view.componentEngine.component = VStack(spacing: 0) {
            Text("A").id("A").size(width: .fill, height: 20)
            Text("X").id("X").size(width: .fill, height: 20)
            Text("C").id("C").size(width: .fill, height: 20)
        }
        view.componentEngine.reloadData()

        #expect(deleteStore.completions.count == 1)
        #expect(labelTexts(in: view) == ["A", "B", "X", "C"])
        #expect((view.subviews.last as? UILabel)?.text == "C")

        deleteStore.completions.forEach { $0() }
        #expect(labelTexts(in: view) == ["A", "X", "C"])
    }

    @Test func testReorderExistingViewsUpdatesSubviewOrder() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        view.componentEngine.component = VStack(spacing: 0) {
            Text("A").id("A").size(width: .fill, height: 20)
            Text("B").id("B").size(width: .fill, height: 20)
            Text("C").id("C").size(width: .fill, height: 20)
        }
        view.componentEngine.reloadData()
        #expect(labelTexts(in: view) == ["A", "B", "C"])

        view.componentEngine.component = VStack(spacing: 0) {
            Text("C").id("C").size(width: .fill, height: 20)
            Text("A").id("A").size(width: .fill, height: 20)
            Text("B").id("B").size(width: .fill, height: 20)
        }
        view.componentEngine.reloadData()

        #expect(labelTexts(in: view) == ["C", "A", "B"])
    }

    private func labelTexts(in view: UIView) -> [String] {
        view.subviews.compactMap {
            ($0 as? UILabel)?.text
        }
    }
}
