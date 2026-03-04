extension ComponentEngine {
    func performLegacyRender(
        hostingView: UIView,
        newVisibleRenderables: [Renderable],
        shouldUpdateViews: Bool
    ) -> [UIView] {
        var newIndexByIdentifier = [String: Int]()
        newIndexByIdentifier.reserveCapacity(newVisibleRenderables.count)
        for (index, renderable) in newVisibleRenderables.enumerated() {
            newIndexByIdentifier[renderable.id] = index
        }

        var newViews = [UIView?](repeating: nil, count: newVisibleRenderables.count)

        // 1st pass: delete removed cells and carry over reusable existing cells.
        for index in 0..<visibleViews.count {
            let oldRenderable = visibleRenderables[index]
            let oldView = visibleViews[index]
            if let newIndex = newIndexByIdentifier[oldRenderable.id] {
                newViews[newIndex] = oldView
            } else {
                let viewAnimator = oldRenderable.renderNode.animator ?? animator
                viewAnimator.shift(hostingView: hostingView, delta: contentOffsetDelta, view: oldView)
                viewAnimator.delete(hostingView: hostingView, view: oldView) {
                    oldView.recycleForUIComponentReuse()
                }
            }
        }

        // 2nd pass: create missing cells, update frames, and restore subview order.
        let containerView = contentView ?? hostingView
        for (index, renderable) in newVisibleRenderables.enumerated() {
            let viewAnimator = renderable.renderNode.animator ?? animator
            let frame = renderable.frame
            let cell: UIView
            if let existingView = newViews[index] {
                cell = existingView
                if shouldUpdateViews {
                    renderable.renderNode._updateView(cell)
                    viewAnimator.shift(hostingView: hostingView, delta: contentOffsetDelta, view: cell)
                }
            } else {
                cell = renderable.renderNode._makeView()
                UIView.performWithoutAnimation {
                    cell.bounds.size = frame.bounds.size
                    cell.center = frame.center
                    cell.layoutIfNeeded()
                    renderable.renderNode._updateView(cell)
                }
                viewAnimator.insert(hostingView: hostingView, view: cell, frame: frame)
                newViews[index] = cell
            }
            viewAnimator.update(hostingView: hostingView, view: cell, frame: frame)
            containerView.insertSubview(cell, at: index)
        }

        return newViews as! [UIView]
    }
}
