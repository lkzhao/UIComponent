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
  
  let defaultData: [CoverModel] = (0...31).map { _ in CoverModel() }
  
  override var component: Component {
    VStack(spacing: 20) {
      
      Text("Irregular layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      for (index, item) in defaultData.chunked(by: 6).enumerated() {
        let position = IrregularComponent.Position.allCases[index % 4]
        VStack(spacing: 10) {
          Text("position: .\(position)")
          IrregularComponent(coverModels: item, position: position, spacing: 5)
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
          let position = IrregularComponent.Position.allCases[index % 4]
          IrregularComponent(coverModels: item, position: position, spacing: 0)
        }
      }.view().backgroundColor(.systemGroupedBackground)
    }.inset(h: 10, v: 20)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
