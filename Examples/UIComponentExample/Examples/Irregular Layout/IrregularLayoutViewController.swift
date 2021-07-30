//
//  IrregularLayoutViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/29.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

class IrregularLayoutViewController: ComponentViewController {
  
  let defaultData: [CoverModel] = (0...32).map { _ in CoverModel() }
  
  let positionExampleData = (1...6).map { _ in CoverModel() }
  
  
  override var component: Component {
    VStack(spacing: 20) {
      
      Text("Irregular layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      for position in IrregularComponent.Position.allCases {
        VStack(spacing: 10) {
          Text("position: .\(position)")
          IrregularComponent(coverModels: positionExampleData, position: position, spacing: 2, showOrder: true)
        }.inset(10).styleColor(.systemGroupedBackground)
      }
      
      Text("Irregular horizontal flow layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      HStack {
        for (index, item) in defaultData.chunked(by: 6).enumerated() {
          let position = IrregularComponent.Position.allCases[index % 4]
          IrregularComponent(coverModels: item, position: position, spacing: 0).view()
        }
      }.size(height: UIScreen.main.bounds.width - 20).scrollView().backgroundColor(.systemGroupedBackground).update {
        $0.layer.cornerRadius = 8
      }
      
      Text("Irregular vertical flow layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      VStack {
        for (index, item) in defaultData.chunked(by: 6).enumerated() {
          IrregularComponent(coverModels: item, position: index % 2 == 1 ? .topRight : .topLeft, spacing: 0)
        }
      }
    }.inset(h: 10, v: 20)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
