//  Created by y H on 2024/4/15.

import UIComponent
import UIKit

extension SwipeActionsExample {
    struct Cell: ComponentBuilder {
        let title: String
        func build() -> some Component {
            HStack(alignItems: .center) {
                Text(title)
            }
            .inset(15)
            .size(height: 60)
            .backgroundColor(.systemIndigo.withAlphaComponent(0.5))
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
        Text("Email Example", font: UIFont.preferredFont(forTextStyle: .largeTitle))
            .inset(h: 30, v: 20)
    }
}

