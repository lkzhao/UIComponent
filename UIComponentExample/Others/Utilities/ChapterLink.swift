//  Created by Luke Zhao on 11/6/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import Foundation

struct ChapterLink: Component {
    let title: String
    let viewType: UIView.Type
    let anchorId: String?
    func layout(_ constraint: Constraint) -> some RenderNode {
        HStack(spacing: 8, alignItems: .center) {
            Text(title, font: .bodyBold)
            Image(systemName: "arrow.up.right").tintColor(.label)
        }.inset(h: 16, v: 12).tappableView {
            guard let homeView = $0.parentHomeView, let chapter = Chapter.all.first(where: { $0.view == viewType }) else { return }
            homeView.viewModel.selected = chapter
            homeView.updateProperties()
            homeView.componentEngine.reloadData()
            if let anchorId {
                homeView.subviews.first(where: { type(of: $0) == viewType })?.scrollToComponent(id: anchorId)
            }
        }
        .codeBlockStyle()
        .eraseToAnyComponent()
        .layout(constraint)
    }
}

fileprivate extension UIView {
    func scrollToComponent(id: String) {
        guard
            let scrollView = subviews.compactMap({ $0 as? UIScrollView }).first,
            let frame = scrollView.componentEngine.frame(id: id) else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: frame.minY - 20), animated: false)
    }
}
#endif
