//
//  IrregularComponents.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/29.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

struct CoverModel: Equatable {
  let id = UUID().uuidString
  let cover: URL = randomWebImage()
}


struct LeadingComponent: ComponentBuilder {
  let coverModels: [CoverModel]
  func build() -> Component {
    Waterfall(columns: 3, spacing: 5) {
      for (index, item) in coverModels.enumerated() {
        AsyncImage(item.cover).size(width: .fill)
      }
    }
  }
}
