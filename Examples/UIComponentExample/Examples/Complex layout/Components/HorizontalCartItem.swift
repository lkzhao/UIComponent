//
//  HorizontalCartItem.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit.UIScreen

struct HorizontalCartItem: ComponentBuilder {
  
  let data: Context
  
  func build() -> Component {
    HStack(spacing: 10, alignItems: .center) {
      VStack(spacing: 5, alignItems: .center) {
        Image(systemName: "hand.tap")
        Text("Tap to delete", font: .systemFont(ofSize: 10))
      }
      Space().size(width: .aspectPercentage(1), height: .fill).inset(10).styleColor(.systemBlue)
      VStack(justifyContent: .spaceAround) {
        Text("This can occupy one line").numberOfLines(2).flex()
        HStack(spacing: 5, alignItems: .center) {
          Text("long long long long long Text", font: .systemFont(ofSize: 14)).textColor(.secondaryLabel).numberOfLines(1).flex()
          Image(systemName: "checkmark.shield.fill")
        }.flex()
      }.flex()
    }.inset(10).size(width: UIScreen.main.bounds.width - 80, height: 100).styleColor(data.fillColor).id(data.id.uuidString)
  }
  
}

extension HorizontalCartItem {
  struct Context: Equatable {
    let fillColor: UIColor
    let id = UUID()
  }
}
