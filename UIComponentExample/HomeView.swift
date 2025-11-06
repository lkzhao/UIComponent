//
//  HomeView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

@Observable
class HomeViewModel {
    var selected: Chapter = Chapter.all[0]
}

class HomeView: UIView {
    let viewModel = HomeViewModel()

    lazy var sidebarView = SidebarView(viewModel: viewModel)

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateProperties() {
        super.updateProperties()
        let viewType = viewModel.selected.view
        componentEngine.component = HStack {
            sidebarView.size(width: 210, height: .fill)
            Separator(color: .label.withAlphaComponent(0.2))
            ViewComponent(generator: viewType.init()).id("\(viewType)").fill().flex()
        }.fill()
    }

    @objc func handleTap() {
        endEditing(true)
    }
}
