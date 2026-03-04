import Testing
@testable import UIComponent

@Suite("View Diff Tests")
@MainActor
struct ViewDiffTests {
    private final class DeferredDeleteStore {
        var completions: [() -> Void] = []
    }

    @Test func testDiffActions() {
        let actions = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c", "d"],
            newIDs: ["a", "x", "c", "y"]
        )
        #expect(actions == [
            .delete(oldIndex: 1),
            .delete(oldIndex: 3),
            .keep(newIndex: 0, oldIndex: 0),
            .insert(newIndex: 1, insertBeforeOldIndex: 2),
            .keep(newIndex: 2, oldIndex: 2),
            .insert(newIndex: 3, insertBeforeOldIndex: nil)
        ])
    }

    @Test func testDiffUnchangedOrderProducesKeepActions() {
        let actions = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c"],
            newIDs: ["a", "b", "c"]
        )
        #expect(actions == [
            .keep(newIndex: 0, oldIndex: 0),
            .keep(newIndex: 1, oldIndex: 1),
            .keep(newIndex: 2, oldIndex: 2)
        ])
    }

    @Test func testDiffMoveActions() {
        let actions = IDDiffHelper.diff(
            oldIDs: ["a", "b", "c"],
            newIDs: ["c", "a", "b"]
        )
        #expect(actions == [
            .move(newIndex: 0, oldIndex: 2, insertBeforeOldIndex: 0),
            .keep(newIndex: 1, oldIndex: 0),
            .keep(newIndex: 2, oldIndex: 1)
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
