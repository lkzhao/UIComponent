//  Created by y H on 2024/4/15.

import UIComponent
import UIKit

extension SwipeActionComponent {
    static func rounded(horizontalEdge: SwipeHorizontalEdge, cornerRadius: CGFloat = 15) -> Self {
        self.init(identifier: UUID().uuidString, horizontalEdge: horizontalEdge) {
            Text("Test")
                .textColor(.secondaryLabel)
                .inset(h: 20)
        } background: {
            ViewComponent()
                .backgroundColor(.systemGroupedBackground)
                .with(\.layer.cornerRadius, cornerRadius)
                .with(\.layer.cornerCurve, .continuous)
        } alert: {
            Space()
        } configHighlightView: { highlightView, isHighlighted in
            UIView.performWithoutAnimation {
                highlightView.layer.cornerRadius = cornerRadius
            }
            highlightView.backgroundColor = .black.withAlphaComponent(isHighlighted ? 0.3 : 0)
        } actionHandler: { completion, action, form in
            completion(.swipeFull(nil))
        }


    }
}

extension SwipeActionsExample {
    
    struct Group: ComponentBuilder {
        let title: String
        let body: [any Component]
        init(title: String, @ComponentArrayBuilder _ body: () -> [any Component]) {
            self.title = title
            self.body = body()
        }
        func build() -> some Component {
            VStack(alignItems: .stretch) {
                Text(title, font: UIFont.preferredFont(forTextStyle: .headline))
                    .inset(top: 15, left: 15, bottom: 10, right: 0)
                VStack(alignItems: .stretch) {
                    for (offset, component) in body.enumerated() {
                        var maskedCorners: CACornerMask {
                            if body.count == 1 {
                                return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
                            } else if offset == body.count - 1 {
                                return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                            } else if offset == 0 {
                                return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                            } else {
                                return []
                            }
                        }
                        if maskedCorners.isEmpty {
                            component
                        } else {
                            component
                                .view()
                                .clipsToBounds(true)
                                .with(\.layer.cornerRadius, 15)
                                .with(\.layer.cornerCurve, .continuous)
                                .with(\.layer.maskedCorners, maskedCorners)
                        }
                    }
                }
                .background {
                    Space()
                        .backgroundColor(.secondarySystemGroupedBackground)
                        .with(\.layer.cornerRadius, 15)
                        .with(\.layer.cornerCurve, .continuous)
                }
            }
            .size(width: .fill)
        }
    }
    
    struct Cell: ComponentBuilder {
        let title: String
        func build() -> some Component {
            HStack(alignItems: .center) {
                Text(title, font: .preferredFont(forTextStyle: .body))
            }
            .inset(15)
            .minSize(height: 44)
        }
    }
    struct Email: ComponentBuilder {
        let data: EmailData
        func build() -> some Component {
            HStack(alignItems: .stretch) {
                VStack(justifyContent: .start, alignItems: .center) {
                    if data.unread {
                        Space(width: 10, height: 10)
                            .backgroundColor(UIColor(red: 0.008, green: 0.475, blue: 0.996, alpha: 1.0))
                            .roundedCorner()
                            .inset(top: 5)
                    }
                }
                .size(width: 30)
                VStack(spacing: 2) {
                    HStack {
                        Text(data.from, font: .systemFont(ofSize: 16, weight: .semibold), numberOfLines: 1, lineBreakMode: .byTruncatingTail)
                            .flex()
                        HStack(spacing: 5, alignItems: .center) {
                            Text(data.date.formatted(), font: .systemFont(ofSize: 16, weight: .regular))
                                .textColor(.secondaryLabel)
                            Image(systemName: "chevron.right")
                                .tintColor(.secondaryLabel)
                                .transform(.identity.scaledBy(x: 0.8, y: 0.8))
                        }
                    }
                    Text(data.subject, font: .systemFont(ofSize: 15, weight: .regular), numberOfLines: 1, lineBreakMode: .byTruncatingTail)
                    Text(data.body, font: .systemFont(ofSize: 15, weight: .regular), numberOfLines: 2, lineBreakMode: .byTruncatingTail)
                        .textColor(.secondaryLabel)
                }
                .flex()
                
            }
            .size(width: .fill)
            .inset(left: 0, rest: 10)
            
        }
    }
    
    func defaultSectionTitle(_ title: String) -> some Component {
        Text(title, font: UIFont.preferredFont(forTextStyle: .largeTitle))
            .inset(h: 30, v: 20)
    }
    
    func defaultSubheadlineTitle(_ title: String) -> some Component {
        Text(title, font: UIFont.preferredFont(forTextStyle: .title2))
            .textColor(.label)
            .inset(h: 10, v: 10)
    }
}

