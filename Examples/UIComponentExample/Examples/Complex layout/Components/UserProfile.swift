//  Created by y H on 2021/7/21.

import Kingfisher
import UIComponent
import UIKit.UIImageView

extension ViewComponent where R.View: UIView {
    fileprivate func shadowAvatar() -> ViewUpdateComponent<Self> {
        update {
            $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 3)
            $0.layer.shadowRadius = 6
            $0.layer.shadowOpacity = 1
        }
    }
}

struct UserProfile: ComponentBuilder {

    let avatar: String
    let userName: String
    let introduce: String

    func build() -> Component {
        HStack(spacing: 10, alignItems: .center) {
            AsyncImage(avatar)
                .contentMode(.scaleAspectFill)
                .clipsToBounds(true)
                .size(width: 64, height: 64)
                .update {
                    $0.layer.cornerRadius = $0.frame.height / 2
                }
                .with(\.layer.borderWidth, 2)
                .with(\.layer.borderColor, UIColor.white.cgColor)
                .view()
                .id("avatar")
                .shadowAvatar()

            VStack(spacing: 4) {
                Text(verbatim: userName)
                Text(verbatim: introduce, font: .systemFont(ofSize: 13, weight: .light)).textColor(.secondaryLabel)
                Text("🤔🤔🤔", font: .systemFont(ofSize: 12, weight: .light)).textColor(.secondaryLabel)
            }
            .flex()

            Image(systemName: "chevron.right").tintColor(.systemGray)
        }
        .inset(15).defaultShadow().id("user-info")
    }
}
