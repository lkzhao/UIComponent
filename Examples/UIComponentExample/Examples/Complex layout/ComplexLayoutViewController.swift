//  Created by y H on 2021/7/21.

import UIComponent
import UIKit.UIButton

class ComplexLayoutViewController: ComponentViewController {

    typealias Tag = (name: String, color: UIColor)

    static let defaultHorizontalListData: [HorizontalCardItem.Context] = (0..<10)
        .map { _ in
            HorizontalCardItem.Context()
        }

    var horizontalListData = defaultHorizontalListData {
        didSet {
            reloadComponent()
        }
    }

    var tags: [Tag] = [
        ("Hello", .systemOrange),
        ("UIComponent", .systemPink),
        ("SwiftUI", .systemRed),
        ("Vue", .systemGreen),
        ("Flex Layout", .systemTeal),
    ]
    {
        didSet {
            reloadComponent()
        }
    }

    var showWeather: Bool = false {
        didSet {
            reloadComponent()
        }
    }

    var isExpanded = false {
        didSet {
            reloadComponent()
        }
    }

    lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.addTarget(self, action: #selector(resetHorizontalListData), for: .touchUpInside)
        return button
    }()

    lazy var shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shuffle", for: .normal)
        button.addTarget(self, action: #selector(shuffleHorizontalListData), for: .touchUpInside)
        return button
    }()

    override var component: any Component {
        VStack(spacing: 20) {
            Text("Complex layouts").font(.boldSystemFont(ofSize: 20)).size(width: .fill).id("label")
            VStack(spacing: 10) {
                UserProfile(
                    avatar: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640",
                    userName: "Jack",
                    introduce: "This is simply amazing"
                )
                if showWeather {
                    HStack(justifyContent: .end, alignItems: .center) {
                        Text("Weather forecast: ")
                        HStack(spacing: 10) {
                            Image(systemName: "sun.dust")
                            Image(systemName: "sun.haze")
                            Image(systemName: "cloud.bolt.rain.fill")
                        }
                        .inset(5).styleColor(.systemGroupedBackground)
                    }
                }
                Text(showWeather ? "Hide weather" : "Show weather").textColor(.systemBlue)
                    .tappableView { [unowned self] in
                        self.showWeather.toggle()
                    }
                    .id("weather-toggle")
            }

            IntroductionCard(isExpanded: isExpanded) { [unowned self] in
                self.isExpanded.toggle()
            }

            Text("Tag view").font(.boldSystemFont(ofSize: 20)).id("label2")
            VStack(spacing: 10) {
                Text("Tags row")
                Flow(spacing: 5, alignItems: .center) {
                    if tags.isEmpty {
                        Text("Empty Tag")
                    } else {
                        for (index, tag) in tags.enumerated() {
                            Text(tag.name).font(.systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.color)
                                .tappableView { [unowned self] in
                                    self.tags.remove(at: index)
                                }
                                .id(tag.name)
                        }
                    }
                    HStack(alignItems: .center) {
                        Image(systemName: "plus")
                        Text("Add new").font(.systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
                    }
                    .inset(h: 10, v: 5).styleColor(.systemGray5)
                    .tappableView { [unowned self] in
                        self.didTapAddTag()
                    }
                }
                .view().with(\.componentEngine.animator, TransformAnimator())
                Separator()
                Text("Tags column")
                FlexColumn(spacing: 5) {
                    if tags.isEmpty {
                        Text("Empty Tag")
                    } else {
                        for (index, tag) in tags.enumerated() {
                            Text(tag.name).font(.systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.color)
                                .tappableView { [unowned self] in
                                    self.tags.remove(at: index)
                                }
                                .id(tag.name)
                        }
                    }
                    HStack(alignItems: .center) {
                        Image(systemName: "plus")
                        Text("Add new").font(.systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
                    }
                    .inset(h: 10, v: 5).styleColor(.systemGray5)
                    .tappableView { [unowned self] in
                        self.didTapAddTag()
                    }
                }
                .size(height: 130)
                .view()
                .with(\.componentEngine.animator, TransformAnimator())

                Text("Shuffle tags").textColor(.systemBlue)
                    .tappableView { [unowned self] in
                        self.tags = self.tags.shuffled()
                    }
            }
            .inset(10).styleColor(.systemGroupedBackground).id("tag")

            VStack(spacing: 10) {
                Text("Horizontal list").inset(left: 10)
                HStack(spacing: 10, alignItems: .center) {
                    if horizontalListData.isEmpty {
                        Text("No data here").font(.systemFont(ofSize: 17, weight: .medium)).flex()
                    } else {
                        for (offset, element) in horizontalListData.enumerated() {
                            HorizontalCardItem(data: element)
                                .tappableView { [unowned self] in
                                    self.horizontalListData.remove(at: offset)
                                }
                        }
                    }
                }
                .inset(top: 5, left: 10, bottom: 0, right: 10).visibleInset(-200).scrollView()
                .showsHorizontalScrollIndicator(false)
                .with(\.componentEngine.onFirstReload) { scrollView in
                    guard let scrollView = scrollView as? UIScrollView else { return }
                    let cellFrame = scrollView.componentEngine.frame(id: ComplexLayoutViewController.defaultHorizontalListData[5].id)!
                    scrollView.scrollRectToVisible(CGRect(center: cellFrame.center, size: scrollView.bounds.size), animated: false)  // scroll to item 5 as the center
                }
                .with(\.componentEngine.animator, TransformAnimator())
                HStack(spacing: 10) {
                    ViewComponent<UIButton>(view: resetButton).isEnabled(horizontalListData != ComplexLayoutViewController.defaultHorizontalListData).id("reset")
                    ViewComponent<UIButton>(view: shuffleButton).isEnabled(!horizontalListData.isEmpty).id("shuffled")
                }
                .inset(left: 10)
            }
            .inset(v: 10).styleColor(.systemGroupedBackground).id("horizontal")
        }
        .inset(20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        componentView.componentEngine.animator = TransformAnimator()
    }

    @objc func resetHorizontalListData() {
        horizontalListData = ComplexLayoutViewController.defaultHorizontalListData
    }

    @objc func shuffleHorizontalListData() {
        horizontalListData = horizontalListData.shuffled()
    }

    func didTapAddTag() {
        let alertController = UIAlertController(
            title: "Tag",
            message: "Create new label",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(cancelAction)

        let confirmAction = UIAlertAction(
            title: "Confirm",
            style: .default,
            handler: { [unowned self] action in
                guard let textField = (alertController.textFields?.first), let text = textField.text, !text.isEmpty else { return }
                self.tags.append((text, .randomSystemColor()))
            }
        )
        alertController.addAction(confirmAction)
        alertController.addTextField { textField in
            textField.placeholder = "Enter new tag name"
        }

        present(
            alertController,
            animated: true,
            completion: nil
        )

    }
}
