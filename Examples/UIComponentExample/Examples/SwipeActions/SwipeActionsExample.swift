//  Created by y H on 2024/4/7.

import UIKit
import UIComponent

class SwipeActionsExample: ComponentViewController {
    var emailDatas = EmailData.mockDatas {
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
        VStack(spacing: 10, alignItems: .stretch) {
            Group(title: "Rounded style") {
                VStack(spacing: 10, alignItems: .stretch) {
                    Cell(title: "Rounded corners")
                        .tappableView {
                            
                        }
                        .tappableViewConfig(TappableViewConfig(onHighlightChanged: { view, isHighlight in
                            UIView.animate(withDuration: 0.25) {
                                view.alpha = isHighlight ? 0.7 : 1
                            }
                        }))
                        .with(\.layer.cornerRadius, 15)
                        .backgroundColor(.systemGroupedBackground)
                        .swipeActions {
                            SwipeActionComponent.rounded(horizontalEdge: .right)
                            SwipeActionComponent.rounded(horizontalEdge: .right)
                            SwipeActionComponent.rounded(horizontalEdge: .left)
                            SwipeActionComponent.rounded(horizontalEdge: .left)
                        }
                        .swipeConfig(SwipeConfig(layoutEffect: .drag,
                                                gap: 10,
                                                spacing: 10,
                                                cornerRadius: 15,
                                                clipsToBounds: false))
                    Cell(title: "Rounded corners 2")
                        .tappableView {
                            
                        }
                        .tappableViewConfig(TappableViewConfig(onHighlightChanged: { view, isHighlight in
                            UIView.animate(withDuration: 0.25) {
                                view.alpha = isHighlight ? 0.7 : 1
                            }
                        }))
                        .with(\.layer.cornerRadius, 15)
                        .backgroundColor(.systemGroupedBackground)
                        .swipeActions {
                            SwipeActionComponent.rounded(horizontalEdge: .right, cornerRadius: 0)
                            SwipeActionComponent.rounded(horizontalEdge: .right, cornerRadius: 0)
                            SwipeActionComponent.rounded(horizontalEdge: .right, cornerRadius: 0)
                            SwipeActionComponent.rounded(horizontalEdge: .left, cornerRadius: 0)
                            SwipeActionComponent.rounded(horizontalEdge: .left, cornerRadius: 0)
                            SwipeActionComponent.rounded(horizontalEdge: .left, cornerRadius: 0)
                        }
                        .swipeConfig(SwipeConfig(layoutEffect: .static,
                                                gap: 1,
                                                spacing: 5,
                                                cornerRadius: 15,
                                                clipsToBounds: false))
                }
                .inset(10)
            }
            Group(title: "LayoutEffect") {
                Join {
                    Cell(title: ".drag")
                        .swipeActions {
                            defaultActions
                        }
                        .swipeConfig(SwipeConfig(layoutEffect: .drag))
                    Cell(title: ".reveal")
                        .swipeActions {
                            defaultActions
                        }
                        .swipeConfig(SwipeConfig(layoutEffect: .reveal))
                    Cell(title: ".static")
                        .swipeActions {
                            defaultActions
                        }
                        .swipeConfig(SwipeConfig(layoutEffect: .static))
                } separator: {
                    Separator()
                        .inset(left: 15)
                }
            }
            Group(title: "SwipeActionAfterHandler") {
                Join {
                    Cell(title: ".hold")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemRed,
                                body: {
                                    Text("Remove")
                                        .font(.systemFont(ofSize: 17, weight: .semibold))
                                        .textColor(.white)
                                        .inset(h: 20)
                                },
                                actionHandler: { completion, _, _ in
                                    completion(.hold)
                                }
                            )
                        }
                    Cell(title: ".close")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemRed,
                                body: {
                                    Text("Remove")
                                        .textColor(.white)
                                        .inset(20)
                                },
                                actionHandler: { completion, _, _ in
                                    completion(.close)
                                }
                            )
                        }
                    Cell(title: ".swipeFull")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemRed,
                                body: {
                                    Text("Remove")
                                        .textColor(.white)
                                        .inset(20)
                                },
                                actionHandler: { completion, _, _ in
                                    completion(.swipeFull())
                                }
                            )
                        }
                    Cell(title: ".alert")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemBlue,
                                body: {
                                    Text("Tap alert")
                                        .textColor(.white)
                                        .inset(20)
                                },
                                alert: {
                                    Text("Alert")
                                        .textColor(.white)
                                        .textAlignment(.center)
                                        .backgroundColor(.systemRed)
                                        .fill()
                                        .flex()
                                },
                                actionHandler: { completion, _, from in
                                    if from == .alert {
                                        completion(.swipeFull(nil))
                                    } else {
                                        completion(.alert)
                                    }
                                }
                            )
                        }
                } separator: {
                    Separator()
                        .inset(left: 15)
                }
            }
            Group(title: "RubberBand") {
                Join {
                    Cell(title: ".rubberBandEnable = true")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemRed,
                                body: {
                                    Text("Remove")
                                        .textColor(.white)
                                        .inset(20)
                                },
                                actionHandler: { completion, _, _ in
                                    completion(.hold)
                                }
                            )
                        }
                        .swipeConfig(SwipeConfig(rubberBandEnable: true))
                    Cell(title: ".rubberBandEnable = false")
                        .swipeActions {
                            SwipeActionComponent(
                                horizontalEdge: .right,
                                backgroundColor: .systemRed,
                                body: {
                                    Text("Remove")
                                        .textColor(.white)
                                        .inset(20)
                                },
                                actionHandler: { completion, _, _ in
                                    completion(.close)
                                }
                            )
                        }
                        .swipeConfig(SwipeConfig(rubberBandEnable: false))
                } separator: {
                    Separator()
                        .inset(left: 15)
                }
            }
            Group(title: "Email example") {
                Join {
                    for value in emailDatas  {
                        Email(data: value)
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
                                    print("调用了", index, completion, form)
                                    handlerEmail(action, data: value, completion: completion, eventForm: form)
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
                                    handlerEmail(action, data: value, completion: completion, eventForm: form)
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
                                    handlerEmail(action, data: value, completion: completion, eventForm: form)
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
                                        handlerEmail(action, data: value, completion: completion, eventForm: form)
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
                                        handlerEmail(action, data: value, completion: completion, eventForm: form)
                                    }
                                }
                            }
                            .swipeConfig(SwipeConfig(layoutEffect: .reveal))
//                            .id(value.from)
                    }
                } separator: {
                    Separator()
                        .inset(left: 30)
                }
            }
        }
        .inset(10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swipe Examples"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(close))
        componentView.contentInsetAdjustmentBehavior = .automatic
        componentView.engine.asyncLayout = true
        componentView.animator = TransformAnimator(cascade: true)
    }

    func handlerEmail(_ action: any SwipeAction, data: EmailData, completion: @escaping SwipeAction.CompletionAfterHandler, eventForm: SwipeActionEventFrom) {
        guard let index = emailDatas.firstIndex(where: { $0.from == data.from }) else { return }
        if action.identifier == "read" {
            var data = emailDatas[index]
            data.unread.toggle()
            emailDatas[index] = data
            completion(.close)
        } else if action.identifier == "trash" {
            if eventForm == .expanded || eventForm == .alert {
                let remove: () -> Void = { [unowned self] in
                    self.emailDatas.remove(at: index)
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
