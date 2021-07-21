//
//  Cell.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit.UIScreen
struct Cell: ComponentBuilder {
  let id: String
  func build() -> Component {
    HStack(spacing: 10, alignItems: .center) {
      Image(systemName: "display.2")
      Space().size(width: .aspectPercentage(1), height: .fill).inset(10).styleColor(.systemBlue)
      VStack(justifyContent: .spaceAround) {
        Text("这里可以占满一行(This can occupy one line)...").numberOfLines(2).flex()
        HStack(spacing: 5, alignItems: .center) {
          Text("long long long long long Text").numberOfLines(1).flex()
          Image(systemName: "checkmark.shield.fill")
        }.flex()
      }.flex()
    }.inset(10).size(width: UIScreen.main.bounds.width - 40, height: 100).styleColor(.systemGroupedBackground).id(id)
  }
  
}
