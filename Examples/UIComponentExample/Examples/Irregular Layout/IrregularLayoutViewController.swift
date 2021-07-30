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
      
      Text("Irregular layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      for position in IrregularComponent.Position.allCases {
        VStack(spacing: 10) {
          Text("position: .\(position)")
          IrregularComponent(coverModels: positionExampleData, position: position, spacing: 2, showOrder: true)
        }.inset(10).styleColor(.systemGroupedBackground)
      }
      
      Text("Irregular horizontal flow layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      HStack(spacing: 2) {
        for (index, item) in horizontalData.chunked(by: 6).enumerated() {
          IrregularComponent(coverModels: item, position: getPosition(index % 3), spacing: 2).view()
        }
      }.size(height: UIScreen.main.bounds.width - 20).scrollView().backgroundColor(.systemGroupedBackground).update {
        $0.layer.cornerRadius = 8
      }
      
      Text("Irregular vertical flow layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      Text("Shuffle").textColor(.systemBlue).tappableView {
        self.verticalData = self.verticalData.shuffled()
      }
      VStack(spacing: 2) {
        for (index, item) in verticalData.chunked(by: 6).enumerated() {
          IrregularComponent(coverModels: item, position: getPosition(index % 3), spacing: 2)
        }
      }
    }.inset(h: 10, v: 20)
  }
  
  private func getPosition(_ index: Int) -> IrregularComponent.Position {
    let position: IrregularComponent.Position
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
