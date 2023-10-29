//  Created by y H on 2023/10/30.

import UIComponent
import UIKit

struct AvatarCircle: ComponentBuilder {
    
    let avatar: AnyViewComponent<UIImageView>
    let nickName: AnyViewComponent<UILabel>
    
    func build() -> UIComponent.Component {
        VStack(spacing: 10, alignItems: .center) {
            avatar
                .contentMode(.scaleAspectFill)
                .clipsToBounds(true)
                .borderColor(.systemGray6)
                .borderWidth(2)
                .roundedCorner()
            nickName
        }
    }
}
