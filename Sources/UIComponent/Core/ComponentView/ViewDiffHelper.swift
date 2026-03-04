/// Helper that computes view-level diff actions between two visible renderable ID lists.
///
/// The result is intentionally index-based so `ComponentEngine` can map actions
/// back to the current `visibleViews` and `visibleRenderables` arrays without
/// materializing extra dictionaries of views.
final class ViewDiffHelper {
    struct Result {
        var deleteActions: [DeleteAction]
        var renderActions: [RenderAction]
    }

    struct DeleteAction: Equatable {
        let oldIndex: Int
    }

    struct RenderAction: Equatable {
        enum Kind: Equatable {
            /// Reuse the view currently at `oldIndex`.
            case keep(oldIndex: Int)
            /// Create a new view and insert it before the existing view at `oldIndex`.
            /// `nil` means append to the end.
            case insert(insertBeforeOldIndex: Int?)
        }

        let newIndex: Int
        let kind: Kind
    }

    static func diff(oldIDs: [String], newIDs: [String]) -> Result {
        var newIndexByID = [String: Int]()
        newIndexByID.reserveCapacity(newIDs.count)
        for (newIndex, id) in newIDs.enumerated() {
            newIndexByID[id] = newIndex
        }

        var keptOldIndexByNewIndex = [Int?](repeating: nil, count: newIDs.count)
        var deleteActions = [DeleteAction]()
        deleteActions.reserveCapacity(oldIDs.count)

        for (oldIndex, id) in oldIDs.enumerated() {
            guard let newIndex = newIndexByID[id], keptOldIndexByNewIndex[newIndex] == nil else {
                deleteActions.append(.init(oldIndex: oldIndex))
                continue
            }
            keptOldIndexByNewIndex[newIndex] = oldIndex
        }

        var insertBeforeOldIndexByNewIndex = [Int?](repeating: nil, count: newIDs.count)
        if !newIDs.isEmpty {
            var nextKeptOldIndex: Int?
            for newIndex in stride(from: newIDs.count - 1, through: 0, by: -1) {
                insertBeforeOldIndexByNewIndex[newIndex] = nextKeptOldIndex
                if let oldIndex = keptOldIndexByNewIndex[newIndex] {
                    nextKeptOldIndex = oldIndex
                }
            }
        }

        var renderActions = [RenderAction]()
        renderActions.reserveCapacity(newIDs.count)
        for newIndex in newIDs.indices {
            if let oldIndex = keptOldIndexByNewIndex[newIndex] {
                renderActions.append(
                    .init(
                        newIndex: newIndex,
                        kind: .keep(oldIndex: oldIndex)
                    )
                )
            } else {
                renderActions.append(
                    .init(
                        newIndex: newIndex,
                        kind: .insert(insertBeforeOldIndex: insertBeforeOldIndexByNewIndex[newIndex])
                    )
                )
            }
        }

        return Result(
            deleteActions: deleteActions,
            renderActions: renderActions
        )
    }
}
