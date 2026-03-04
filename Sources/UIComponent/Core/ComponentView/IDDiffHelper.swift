/// Generic helper that computes ordered diff actions between old/new ID lists.
///
/// This helper intentionally knows nothing about views, renderables, or animators.
final class IDDiffHelper {
    enum Action: Equatable {
        /// Remove existing item at old index.
        case delete(oldIndex: Int)
        /// Reuse existing item from old index for new index.
        case keep(newIndex: Int, oldIndex: Int)
        /// Reorder existing item at old index to new index before another old index (or append when nil).
        case move(newIndex: Int, oldIndex: Int, insertBeforeOldIndex: Int?)
        /// Insert new item at new index before another old index (or append when nil).
        case insert(newIndex: Int, insertBeforeOldIndex: Int?)
    }

    static func diff(oldIDs: [String], newIDs: [String]) -> [Action] {
        if oldIDs == newIDs { return keepActions(count: newIDs.count) }

        var newIndexByID = [String: Int]()
        newIndexByID.reserveCapacity(newIDs.count)
        for (newIndex, id) in newIDs.enumerated() {
            newIndexByID[id] = newIndex
        }

        var keptOldIndexByNewIndex = [Int?](repeating: nil, count: newIDs.count)
        var deleteOldIndices = [Int]()
        deleteOldIndices.reserveCapacity(oldIDs.count)
        var keptOldIndicesInOldOrder = [Int]()
        keptOldIndicesInOldOrder.reserveCapacity(min(oldIDs.count, newIDs.count))

        for (oldIndex, id) in oldIDs.enumerated() {
            guard let newIndex = newIndexByID[id], keptOldIndexByNewIndex[newIndex] == nil else {
                deleteOldIndices.append(oldIndex)
                continue
            }
            keptOldIndexByNewIndex[newIndex] = oldIndex
            keptOldIndicesInOldOrder.append(oldIndex)
        }

        let moveActions = moveActions(
            keptOldIndicesInOldOrder: keptOldIndicesInOldOrder,
            keptOldIndicesInNewOrder: keptOldIndexByNewIndex.compactMap { $0 }
        )
        let moveActionByOldIndex = Dictionary(uniqueKeysWithValues: moveActions.map {
            ($0.oldIndex, $0)
        })

        var insertBeforeOldIndexByNewIndex = [Int?](repeating: nil, count: keptOldIndexByNewIndex.count)
        if !newIDs.isEmpty {
            var nextKeptOldIndex: Int?
            for newIndex in stride(from: newIDs.count - 1, through: 0, by: -1) {
                if let oldIndex = keptOldIndexByNewIndex[newIndex] {
                    nextKeptOldIndex = oldIndex
                } else {
                    insertBeforeOldIndexByNewIndex[newIndex] = nextKeptOldIndex
                }
            }
        }

        var actions = [Action]()
        actions.reserveCapacity(deleteOldIndices.count + newIDs.count)

        for oldIndex in deleteOldIndices {
            actions.append(.delete(oldIndex: oldIndex))
        }
        for newIndex in newIDs.indices {
            if let oldIndex = keptOldIndexByNewIndex[newIndex] {
                if let moveAction = moveActionByOldIndex[oldIndex] {
                    actions.append(
                        .move(
                            newIndex: newIndex,
                            oldIndex: oldIndex,
                            insertBeforeOldIndex: moveAction.insertBeforeOldIndex
                        )
                    )
                } else {
                    actions.append(.keep(newIndex: newIndex, oldIndex: oldIndex))
                }
            } else {
                actions.append(.insert(newIndex: newIndex, insertBeforeOldIndex: insertBeforeOldIndexByNewIndex[newIndex]))
            }
        }

        return actions
    }

    private struct MoveAction {
        let oldIndex: Int
        let insertBeforeOldIndex: Int?
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

    private static func keepActions(count: Int) -> [Action] {
        var actions = [Action]()
        actions.reserveCapacity(count)
        for index in 0..<count {
            actions.append(.keep(newIndex: index, oldIndex: index))
        }
        return actions
    }
}
