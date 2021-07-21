//
//  Modifiers.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent
extension Component {
  func styleColor(_ tintColor: UIColor) -> ViewUpdateComponent<ComponentDisplayableViewComponent<ComponentView>> {
    view().update {
      $0.backgroundColor = tintColor.withAlphaComponent(0.5)
      $0.layer.cornerRadius = 10
      $0.layer.cornerCurve = .continuous
      $0.layer.borderWidth = 2
      $0.layer.borderColor = tintColor.cgColor
    }
  }
}
