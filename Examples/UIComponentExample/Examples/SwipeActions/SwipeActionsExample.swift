//  Created by y H on 2024/4/7.

import UIKit
import UIComponent

class SwipeActionsExample: ComponentViewController {
    var emailData = EmailData.mockDatas {
        didSet {
            reloadComponent()
        }
    }

    var customSwipeAction: SwipeActionComponent {
        var primaryMenuSwipeAction = SwipeActionComponent.custom(
            horizontalEdge: .left,
            backgroundColor: UIColor(red: 0.341, green: 0.333, blue: 0.835, alpha: 1.0),
            alert: {
                Text("This is custom action", font: .systemFont(ofSize: 18, weight: .medium))
                    .textColor(.white)
                    .adjustsFontSizeToFitWidth(true)
                    .textAlignment(.center)
                    .inset(5)
                    .flex()
            },
            actionHandler: { [unowned self] completion, _, form in
                if form == .alert {
                    completion(.swipeFull {
                        self.present(ComponentViewController(), animated: true)
                    })
                }
            }
        )
        let primaryMenuComponent = VStack(alignItems: .center) {
            Image(systemName: "clock.fill")
                .tintColor(.white)
            Text("Remind", font: .systemFont(ofSize: 16, weight: .medium))
                .textColor(.white)
        }
        .inset(h: 10)
        .minSize(width: 74)
        .primaryMenu {
            let actionHandler: UIActionHandler = { action in
                if action.title == "Remind me later..." {
                    primaryMenuSwipeAction.manualHandlerAfter(afterHandler: .alert)
                } else if action.title == "Remind me in 1 hour" {
                    primaryMenuSwipeAction.manualHandlerAfter(afterHandler: .hold)
                    let alert = UIAlertController(title: "Alert", message: "Hold swipe...", preferredStyle: .alert)
                    [SwipeActionAfterHandler.alert, SwipeActionAfterHandler.close, SwipeActionAfterHandler.swipeFull(nil)]
                        .map { value in
                            UIAlertAction(title: String(describing: value), style: .default) { _ in
                                primaryMenuSwipeAction.manualHandlerAfter(afterHandler: value)
                            }
                        }.forEach { alert.addAction($0) }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true)
                } else {
                    primaryMenuSwipeAction.manualHandlerAfter(afterHandler: .close)
                }
            }
            return UIMenu(title: "Remind me", children: [
                UIAction(title: "Remind me in 1 hour", handler: actionHandler),
                UIAction(title: "Remind me tomorrow", handler: actionHandler),
                UIAction(title: "Remind me later...", handler: actionHandler),
            ])
        }
        primaryMenuSwipeAction.component = primaryMenuComponent
        return primaryMenuSwipeAction
    }

    override var component: any Component {
        VStack(alignItems: .stretch) {
            Join {
                for (index, value) in emailData.enumerated() {
                    Email(data: value)
                        .id(value.from)
                        .tappableView { [unowned self] in
                            self.navigationController?.pushViewController(ComponentViewController(), animated: true)
                        }
                        .swipeActions {
                            customSwipeAction
                            SwipeActionComponent(identifier: "read", horizontalEdge: .left, backgroundColor: UIColor(red: 0.008, green: 0.475, blue: 0.996, alpha: 1.0)) {
                                VStack(justifyContent: .center, alignItems: .center) {
                                    Image(systemName: value.unread ? "envelope.open.fill" : "envelope.fill")
                                        .tintColor(.white)
                                    Text(value.unread ? "Read" : "Unread", font: .systemFont(ofSize: 16, weight: .medium))
                                        .textColor(.white)
                                }
                                .inset(h: 10)
                                .minSize(width: 74, height: 0)
                            } actionHandler: { [unowned self] completion, action, form in
                                handlerEmail(action, completion: completion, eventForm: form, index: index)
                            }

                            // MARK: Right
                            SwipeActionComponent(identifier: "more", horizontalEdge: .right, backgroundColor: UIColor(red: 0.553, green: 0.553, blue: 0.553, alpha: 1.0)) {
                                VStack(justifyContent: .center, alignItems: .center) {
                                    Image(systemName: "ellipsis.circle.fill")
                                        .tintColor(.white)
                                    Text("More", font: .systemFont(ofSize: 16, weight: .medium))
                                        .textColor(.white)
                                }
                                .inset(h: 10)
                                .minSize(width: 74, height: 0)
                            } actionHandler: { [unowned self] completion, action, form in
                                handlerEmail(action, completion: completion, eventForm: form, index: index)
                            }
                            SwipeActionComponent(identifier: "flag", horizontalEdge: .right, backgroundColor: UIColor(red: 0.996, green: 0.624, blue: 0.024, alpha: 1.0)) {
                                VStack(justifyContent: .center, alignItems: .center) {
                                    Image(systemName: "flag.fill")
                                        .tintColor(.white)
                                    Text("Flag", font: .systemFont(ofSize: 16, weight: .medium))
                                        .textColor(.white)
                                }
                                .inset(h: 10)
                                .minSize(width: 74, height: 0)
                            } actionHandler: { [unowned self] completion, action, form in
                                handlerEmail(action, completion: completion, eventForm: form, index: index)
                            }
                            if value.unread {
                                SwipeActionComponent(identifier: "archive", horizontalEdge: .right, backgroundColor: UIColor(red: 0.749, green: 0.349, blue: 0.945, alpha: 1.0)) {
                                    VStack(justifyContent: .center, alignItems: .center) {
                                        Image(systemName: "archivebox.fill")
                                            .tintColor(.white)
                                        Text("Archive", font: .systemFont(ofSize: 16, weight: .medium))
                                            .textColor(.white)
                                    }
                                    .inset(h: 10)
                                    .minSize(width: 74, height: 0)
                                } actionHandler: { [unowned self] completion, action, form in
                                    handlerEmail(action, completion: completion, eventForm: form, index: index)
                                }
                            } else {
                                SwipeActionComponent(identifier: "trash", horizontalEdge: .right, backgroundColor: UIColor(red: 0.996, green: 0.271, blue: 0.227, alpha: 1.0)) {
                                    VStack(justifyContent: .center, alignItems: .center) {
                                        Image(systemName: "trash.fill")
                                            .tintColor(.white)
                                        Text("Trash", font: .systemFont(ofSize: 16, weight: .medium))
                                            .textColor(.white)
                                    }
                                    .inset(h: 10)
                                    .minSize(width: 74, height: 0)
                                } alert: {
                                    HStack(spacing: 5, justifyContent: .center, alignItems: .center) {
                                        Image(systemName: "trash.fill")
                                            .tintColor(.white)
                                        Text("Are you sure?", font: .systemFont(ofSize: 20, weight: .semibold))
                                            .textColor(.white)
                                    }
                                } actionHandler: { [unowned self] completion, action, form in
                                    handlerEmail(action, completion: completion, eventForm: form, index: index)
                                }
                            }
                        }
                }
            } separator: {
                Separator()
                    .inset(left: 30)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(close))
        navigationController?.navigationBar.prefersLargeTitles = true
        componentView.contentInsetAdjustmentBehavior = .automatic
        componentView.engine.asyncLayout = true
        componentView.animator = TransformAnimator(cascade: true)
        title = "Email Example"
    }

    func handlerEmail(_ action: any SwipeAction, completion: @escaping SwipeAction.CompletionAfterHandler, eventForm: SwipeActionEventFrom, index: Int) {
        if action.identifier == "read" {
            emailData[index].unread.toggle()
            completion(.close)
        } else if action.identifier == "trash" {
            if eventForm == .expanded || eventForm == .alert {
                let remove: () -> Void = { [unowned self] in
                    self.emailData.remove(at: index)
                }
                completion(.swipeFull(remove))
            } else {
                completion(.alert)
            }
        } else {
            completion(.close)
        }
    }

    @objc func close() {
        dismiss(animated: true)
    }
}
