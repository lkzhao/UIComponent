/// Applies ID diff actions to a `ComponentEngine`'s current view hierarchy.
final class ComponentViewDiffApplier {
    private struct Context {
        let oldRenderables: [Renderable]
        let oldViews: [UIView]
        let newRenderables: [Renderable]
        let hostingView: UIView
        let containerView: UIView
        let contentOffsetDelta: CGPoint
        let rootAnimator: Animator
        let shouldUpdateViews: Bool

        func animator(for renderable: Renderable) -> Animator {
            renderable.renderNode.animator ?? rootAnimator
        }
    }

    static func apply(
        componentEngine: ComponentEngine,
        newRenderables: [Renderable],
        shouldUpdateViews: Bool
    ) -> [UIView] {
        guard let context = makeContext(
            componentEngine: componentEngine,
            newRenderables: newRenderables,
            shouldUpdateViews: shouldUpdateViews
        ) else {
            return []
        }

        let diffActions = IDDiffHelper.diff(
            oldIDs: context.oldRenderables.map(\.id),
            newIDs: newRenderables.map(\.id)
        )

        var newViews = [UIView?](repeating: nil, count: context.newRenderables.count)
        applyActions(
            actions: diffActions,
            into: &newViews,
            context: context
        )
        let resolvedViews = newViews.compactMap { $0 }
        precondition(
            resolvedViews.count == context.newRenderables.count,
            "ComponentViewDiffApplier.apply did not resolve views for all new renderables"
        )
        return resolvedViews
    }

    private static func makeContext(
        componentEngine: ComponentEngine,
        newRenderables: [Renderable],
        shouldUpdateViews: Bool
    ) -> Context? {
        guard let hostingView = componentEngine.view else { return nil }
        return Context(
            oldRenderables: componentEngine.visibleRenderables,
            oldViews: componentEngine.visibleViews,
            newRenderables: newRenderables,
            hostingView: hostingView,
            containerView: componentEngine.contentView ?? hostingView,
            contentOffsetDelta: componentEngine.contentOffsetDelta,
            rootAnimator: componentEngine.animator,
            shouldUpdateViews: shouldUpdateViews
        )
    }

    private static func applyActions(
        actions: [IDDiffHelper.Action],
        into newViews: inout [UIView?],
        context: Context
    ) {
        for action in actions {
            switch action {
            case let .delete(oldIndex):
                deleteView(oldIndex: oldIndex, context: context)
            case let .keep(newIndex, oldIndex):
                renderKeptView(
                    newIndex: newIndex,
                    oldIndex: oldIndex,
                    into: &newViews,
                    context: context
                )
            case let .move(newIndex, oldIndex, insertBeforeOldIndex):
                renderMovedView(
                    newIndex: newIndex,
                    oldIndex: oldIndex,
                    insertBeforeOldIndex: insertBeforeOldIndex,
                    into: &newViews,
                    context: context
                )
            case let .insert(newIndex, insertBeforeOldIndex):
                renderInsertedView(
                    newIndex: newIndex,
                    insertBeforeOldIndex: insertBeforeOldIndex,
                    into: &newViews,
                    context: context
                )
            }
        }
    }

    private static func deleteView(oldIndex: Int, context: Context) {
        let renderable = context.oldRenderables[oldIndex]
        let cell = context.oldViews[oldIndex]
        let animator = context.animator(for: renderable)
        animator.shift(
            hostingView: context.hostingView,
            delta: context.contentOffsetDelta,
            view: cell
        )
        animator.delete(hostingView: context.hostingView, view: cell) {
            cell.recycleForUIComponentReuse()
        }
    }

    private static func moveView(
        oldIndex: Int,
        insertBeforeOldIndex: Int?,
        context: Context
    ) {
        let movingView = context.oldViews[oldIndex]
        guard movingView.superview === context.containerView else { return }
        insert(
            movingView,
            beforeOldIndex: insertBeforeOldIndex,
            oldViews: context.oldViews,
            in: context.containerView
        )
    }

    private static func renderKeptView(
        newIndex: Int,
        oldIndex: Int,
        into newViews: inout [UIView?],
        context: Context
    ) {
        let renderable = context.newRenderables[newIndex]
        let cell = context.oldViews[oldIndex]
        let animator = context.animator(for: renderable)
        updateExistingView(
            renderable: renderable,
            cell: cell,
            animator: animator,
            context: context
        )
        animator.update(hostingView: context.hostingView, view: cell, frame: renderable.frame)
        newViews[newIndex] = cell
    }

    private static func renderMovedView(
        newIndex: Int,
        oldIndex: Int,
        insertBeforeOldIndex: Int?,
        into newViews: inout [UIView?],
        context: Context
    ) {
        moveView(
            oldIndex: oldIndex,
            insertBeforeOldIndex: insertBeforeOldIndex,
            context: context
        )
        renderKeptView(
            newIndex: newIndex,
            oldIndex: oldIndex,
            into: &newViews,
            context: context
        )
    }

    private static func renderInsertedView(
        newIndex: Int,
        insertBeforeOldIndex: Int?,
        into newViews: inout [UIView?],
        context: Context
    ) {
        let renderable = context.newRenderables[newIndex]
        let animator = context.animator(for: renderable)
        let cell = makeInsertedView(
            renderable: renderable,
            animator: animator,
            insertBeforeOldIndex: insertBeforeOldIndex,
            context: context
        )
        animator.update(hostingView: context.hostingView, view: cell, frame: renderable.frame)
        newViews[newIndex] = cell
    }

    private static func updateExistingView(
        renderable: Renderable,
        cell: UIView,
        animator: Animator,
        context: Context
    ) {
        guard context.shouldUpdateViews else { return }
        renderable.renderNode._updateView(cell)
        animator.shift(
            hostingView: context.hostingView,
            delta: context.contentOffsetDelta,
            view: cell
        )
    }

    private static func makeInsertedView(
        renderable: Renderable,
        animator: Animator,
        insertBeforeOldIndex: Int?,
        context: Context
    ) -> UIView {
        let cell = renderable.renderNode._makeView()
        let frame = renderable.frame
        UIView.performWithoutAnimation {
            cell.bounds.size = frame.bounds.size
            cell.center = frame.center
            cell.layoutIfNeeded()
            renderable.renderNode._updateView(cell)
        }
        animator.insert(hostingView: context.hostingView, view: cell, frame: frame)
        insert(
            cell,
            beforeOldIndex: insertBeforeOldIndex,
            oldViews: context.oldViews,
            in: context.containerView
        )
        return cell
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
