//  Created by y H on 2021/7/21.

import UIComponent
import UIKit

extension Component {

    func styleColor(_ tintColor: UIColor) -> UpdateComponent<ComponentViewComponent<ComponentView>> {
        view()
            .update {
                $0.backgroundColor = tintColor.withAlphaComponent(0.5)
                $0.layer.cornerRadius = 10
                $0.layer.cornerCurve = .continuous
                $0.layer.borderWidth = 2
                $0.layer.borderColor = tintColor.cgColor
            }
    }

    func defaultShadow() -> UpdateComponent<ComponentViewComponent<ComponentView>> {
        view()
            .update {
                $0.backgroundColor = .systemBackground
                $0.layer.cornerRadius = 10
                $0.layer.cornerCurve = .continuous
                $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
                $0.layer.shadowOffset = CGSize(width: 0, height: 3)
                $0.layer.shadowRadius = 10
                $0.layer.shadowOpacity = 1
            }
    }

}
