/// Generic helper that computes ordered diff actions between old/new ID lists.
///
/// This helper intentionally knows nothing about views, renderables, or animators.
final class IDDiffHelper {
    struct Result {
        var deleteActions: [DeleteAction]
        var moveActions: [MoveAction]
        var renderActions: [RenderAction]
        var unchangedOrderCount: Int?
    }

    struct DeleteAction: Equatable {
        let oldIndex: Int
    }

    struct MoveAction: Equatable {
        let oldIndex: Int
        let insertBeforeOldIndex: Int?
    }

    struct RenderAction: Equatable {
        enum Kind: Equatable {
            /// Reuse the item currently at `oldIndex`.
            case keep(oldIndex: Int)
            /// Create a new item and insert it before the existing item at `oldIndex`.
            /// `nil` means append to the end.
            case insert(insertBeforeOldIndex: Int?)
        }

        let newIndex: Int
        let kind: Kind
    }

    static func diff(oldIDs: [String], newIDs: [String]) -> Result {
        if oldIDs.count == newIDs.count &&
            zip(oldIDs, newIDs).allSatisfy({ pair in pair.0 == pair.1 }) {
            return Result(
                deleteActions: [],
                moveActions: [],
                renderActions: [],
                unchangedOrderCount: newIDs.count
            )
        }

        var newIndexByID = [String: Int]()
        newIndexByID.reserveCapacity(newIDs.count)
        for (newIndex, id) in newIDs.enumerated() {
            newIndexByID[id] = newIndex
        }

        var keptOldIndexByNewIndex = [Int?](repeating: nil, count: newIDs.count)
        var deleteActions = [DeleteAction]()
        deleteActions.reserveCapacity(oldIDs.count)
        var keptOldIndicesInOldOrder = [Int]()
        keptOldIndicesInOldOrder.reserveCapacity(min(oldIDs.count, newIDs.count))

        for (oldIndex, id) in oldIDs.enumerated() {
            guard let newIndex = newIndexByID[id], keptOldIndexByNewIndex[newIndex] == nil else {
                deleteActions.append(.init(oldIndex: oldIndex))
                continue
            }
            keptOldIndexByNewIndex[newIndex] = oldIndex
            keptOldIndicesInOldOrder.append(oldIndex)
        }

        let keptOldIndicesInNewOrder = keptOldIndexByNewIndex.compactMap { $0 }
        let moveActions = moveActions(
            keptOldIndicesInOldOrder: keptOldIndicesInOldOrder,
            keptOldIndicesInNewOrder: keptOldIndicesInNewOrder
        )

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
            moveActions: moveActions,
            renderActions: renderActions,
            unchangedOrderCount: nil
        )
    }

    private static func moveActions(
        keptOldIndicesInOldOrder: [Int],
        keptOldIndicesInNewOrder: [Int]
    ) -> [MoveAction] {
        guard keptOldIndicesInNewOrder.count > 1 else { return [] }

        var oldPositionByOldIndex = [Int: Int]()
        oldPositionByOldIndex.reserveCapacity(keptOldIndicesInOldOrder.count)
        for (position, oldIndex) in keptOldIndicesInOldOrder.enumerated() {
            oldPositionByOldIndex[oldIndex] = position
        }

        var sequence = [Int]()
        sequence.reserveCapacity(keptOldIndicesInNewOrder.count)
        for oldIndex in keptOldIndicesInNewOrder {
            guard let oldPosition = oldPositionByOldIndex[oldIndex] else { continue }
            sequence.append(oldPosition)
        }

        let lisIndices = longestIncreasingSubsequenceIndices(in: sequence)
        var moveActions = [MoveAction]()
        moveActions.reserveCapacity(max(0, keptOldIndicesInNewOrder.count - lisIndices.count))

        var nextAnchorOldIndex: Int?
        for newKeptIndex in stride(from: keptOldIndicesInNewOrder.count - 1, through: 0, by: -1) {
            let oldIndex = keptOldIndicesInNewOrder[newKeptIndex]
            if lisIndices.contains(newKeptIndex) {
                nextAnchorOldIndex = oldIndex
            } else {
                moveActions.append(
                    .init(
                        oldIndex: oldIndex,
                        insertBeforeOldIndex: nextAnchorOldIndex
                    )
                )
                nextAnchorOldIndex = oldIndex
            }
        }

        return moveActions
    }

    private static func longestIncreasingSubsequenceIndices(in sequence: [Int]) -> Set<Int> {
        guard !sequence.isEmpty else { return [] }

        var tails = [Int]()
        tails.reserveCapacity(sequence.count)

        var tailIndices = [Int]()
        tailIndices.reserveCapacity(sequence.count)

        var predecessors = [Int](repeating: -1, count: sequence.count)

        for (index, value) in sequence.enumerated() {
            let position = lowerBound(in: tails, value: value)
            if position == tails.count {
                tails.append(value)
                tailIndices.append(index)
            } else {
                tails[position] = value
                tailIndices[position] = index
            }

            if position > 0 {
                predecessors[index] = tailIndices[position - 1]
            }
        }

        var lisIndices = Set<Int>()
        if let lastIndex = tailIndices.last {
            var index = lastIndex
            while index >= 0 {
                lisIndices.insert(index)
                index = predecessors[index]
            }
        }
        return lisIndices
    }

    private static func lowerBound(in values: [Int], value: Int) -> Int {
        var low = 0
        var high = values.count
        while low < high {
            let mid = (low + high) / 2
            if values[mid] < value {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}
