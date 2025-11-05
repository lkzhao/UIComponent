//
//  SidebarView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

class SidebarView: UIView {
    let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack {
            for chapter in Chapter.all {
                let isSelected = viewModel.selected == chapter
                VStack {
                    Text(chapter.title, font: isSelected ? .subtitle : .body)
                }.inset(h: 12, v: 10).size(width: .fill).tappableView {
                    viewModel.selected = chapter
                }.backgroundColor(
                    isSelected ? .secondarySystemFill : .clear
                ).cornerRadius(8.0).cornerCurve(.continuous)
            }
        }
        .inset(h: 10, v: 20)
        .ignoreHeightConstraint()
        .scrollView()
        .contentInsetAdjustmentBehavior(.always)
        .fill()
    }
}
