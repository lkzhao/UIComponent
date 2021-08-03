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
  
  var verticalData: [CoverModel] = (0...33).map { _ in CoverModel() } {
    didSet {
      reloadComponent()
    }
  }
  
  let horizontalData: [CoverModel] = (0...33).map { _ in CoverModel() }
  
  let positionExampleData = (1...6).map { _ in CoverModel() }
  
  
  override var component: Component {
    VStack(spacing: 20) {
      
      Text("Irregular simple layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      for type in LayoutType.allCases {
        VStack(spacing: 10) {
          Text("type: .\(type)")
          IrregularSimpleComponent(coverModels: positionExampleData, type: type, spacing: 2, showOrder: true)
        }.inset(10).styleColor(.systemGroupedBackground)
      }
      
      Text("Irregular simple horizontal flow layouts").size(width: .fill)
      HStack(spacing: 2) {
        for (index, item) in horizontalData.chunked(by: 6).enumerated() {
          IrregularSimpleComponent(coverModels: item, type: getPosition(index % 3), spacing: 2).view()
        }
      }.size(height: UIScreen.main.bounds.width - 20).scrollView().backgroundColor(.systemGroupedBackground).update {
        $0.layer.cornerRadius = 8
      }
      
      Text("Irregular simple vertical flow layouts").size(width: .fill)
      Text("Shuffle").textColor(.systemBlue).tappableView {
        self.verticalData = self.verticalData.shuffled()
      }
      VStack(spacing: 2) {
        for (index, item) in verticalData.chunked(by: 6).enumerated() {
          IrregularSimpleComponent(coverModels: item, type: getPosition(index % 3), spacing: 2)
        }
      }
      
      Text("Irregular custom layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      VStack(spacing: 2) {
        IrregularCustomComponent(coverModels: verticalData, configLayout: { index in
          let newIndex = index % 4
          if newIndex == 0 {
            return .layout1
          } else if newIndex == 1 {
            return .layout2
          } else if newIndex == 2 {
            return .topLeft
          } else {
            return .topRight
          }
        }, spacing: 2, showOrder: false)
      }
      
    }.inset(h: 10, v: 20)
  }
  
  private func getPosition(_ index: Int) -> LayoutType {
    let position: LayoutType
    if index == 1 {
      position = .topRight
    } else if index == 2 {
      position = .layout1
    } else {
      position = .topLeft
    }
    return position
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
}
