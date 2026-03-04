/// Applies ID diff actions to a `ComponentEngine`'s current view hierarchy.
final class ComponentViewDiffApplier {
    static func apply(
        componentEngine: ComponentEngine,
        newRenderables: [Renderable],
        shouldUpdateViews: Bool
    ) -> [UIView?] {
        let oldRenderables = componentEngine.visibleRenderables
        let oldViews = componentEngine.visibleViews
        let diff = IDDiffHelper.diff(
            oldIDs: oldRenderables.map(\.id),
            newIDs: newRenderables.map(\.id)
        )

        guard let hostingView = componentEngine.view else {
            return [UIView?](repeating: nil, count: newRenderables.count)
        }

        let containerView = componentEngine.contentView ?? hostingView
        let contentOffsetDelta = componentEngine.contentOffsetDelta
        let rootAnimator = componentEngine.animator

        if let unchangedOrderCount = diff.unchangedOrderCount {
            precondition(
                unchangedOrderCount == oldRenderables.count &&
                    unchangedOrderCount == oldViews.count &&
                    unchangedOrderCount == newRenderables.count,
                "ComponentViewDiffApplier.apply received inconsistent unchanged-order context"
            )

            var newViews = [UIView?](repeating: nil, count: newRenderables.count)
            for index in 0..<unchangedOrderCount {
                let renderable = newRenderables[index]
                let cell = oldViews[index]
                let frame = renderable.frame
                let cellAnimator = renderable.renderNode.animator ?? rootAnimator
                if shouldUpdateViews {
                    renderable.renderNode._updateView(cell)
                    cellAnimator.shift(
                        hostingView: hostingView,
                        delta: contentOffsetDelta,
                        view: cell
                    )
                }
                cellAnimator.update(
                    hostingView: hostingView,
                    view: cell,
                    frame: frame
                )
                newViews[index] = cell
            }
            return newViews
        }

        var newViews = [UIView?](repeating: nil, count: newRenderables.count)

        for action in diff.deleteActions {
            let renderable = oldRenderables[action.oldIndex]
            let cell = oldViews[action.oldIndex]
            let cellAnimator = renderable.renderNode.animator ?? rootAnimator
            cellAnimator.shift(
                hostingView: hostingView,
                delta: contentOffsetDelta,
                view: cell
            )
            cellAnimator.delete(hostingView: hostingView, view: cell) {
                cell.recycleForUIComponentReuse()
            }
        }

        for action in diff.moveActions {
            let movingView = oldViews[action.oldIndex]
            guard movingView.superview === containerView else { continue }
            insert(
                movingView,
                beforeOldIndex: action.insertBeforeOldIndex,
                oldViews: oldViews,
                in: containerView
            )
        }

        for action in diff.renderActions {
            let renderable = newRenderables[action.newIndex]
            let frame = renderable.frame
            let cellAnimator = renderable.renderNode.animator ?? rootAnimator
            let cell: UIView

            switch action.kind {
            case let .keep(oldIndex):
                cell = oldViews[oldIndex]
                if shouldUpdateViews {
                    renderable.renderNode._updateView(cell)
                    cellAnimator.shift(
                        hostingView: hostingView,
                        delta: contentOffsetDelta,
                        view: cell
                    )
                }
            case let .insert(insertBeforeOldIndex):
                cell = renderable.renderNode._makeView()
                UIView.performWithoutAnimation {
                    cell.bounds.size = frame.bounds.size
                    cell.center = frame.center
                    cell.layoutIfNeeded()
                    renderable.renderNode._updateView(cell)
                }
                cellAnimator.insert(hostingView: hostingView, view: cell, frame: frame)
                insert(
                    cell,
                    beforeOldIndex: insertBeforeOldIndex,
                    oldViews: oldViews,
                    in: containerView
                )
            }

            cellAnimator.update(
                hostingView: hostingView,
                view: cell,
                frame: frame
            )
            newViews[action.newIndex] = cell
        }

        return newViews
    }

    private static func insert(
        _ view: UIView,
        beforeOldIndex: Int?,
        oldViews: [UIView],
        in containerView: UIView
    ) {
        if let beforeOldIndex {
            let insertBeforeView = oldViews[beforeOldIndex]
            if insertBeforeView.superview === containerView {
                containerView.insertSubview(view, belowSubview: insertBeforeView)
            } else {
                containerView.addSubview(view)
            }
        } else {
            containerView.addSubview(view)
        }
    }
}
