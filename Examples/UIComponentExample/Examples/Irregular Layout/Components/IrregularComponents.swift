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


struct IrregularComponent: ComponentBuilder {
  enum Position: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight, layout1
  }
  let coverModels: [CoverModel]
  let position: Position
  let spacing: CGFloat
  let showOrder: Bool
  
  init(coverModels: [CoverModel], position: Position, spacing: CGFloat, showOrder: Bool = false) {
    self.coverModels = coverModels
    self.position = position
    self.spacing = spacing
    self.showOrder = showOrder
  }
  
  func build() -> Component {
    CustomizeLayout {
      for (index, item) in coverModels.enumerated() {
        AsyncImage(item.cover).contentMode(.scaleAspectFill).clipsToBounds(true).id(item.id).overlay(showOrder ? Text("\(index)").textColor(.white).textAlignment(.center).backgroundColor(UIColor.black.withAlphaComponent(0.5)) : Space())
      }
    } blockFrames: { constraint in
      return Array(genFrames(side: min(constraint.maxSize.width, constraint.maxSize.height), spacing: spacing, position: position).prefix(coverModels.count))
    }
  }
  
  private func genFrames(side: CGFloat, spacing: CGFloat, position: Position) -> [CGRect] {
    let minWidth = (side - (spacing * 2)) / 3.0
    let maxWidth = (side - spacing) - minWidth
    let minHeight = minWidth
    let maxHeight = maxWidth
    
    switch position {
    case .topLeft:
      return [
        CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight),
        CGRect(x: maxWidth + spacing, y: 0, width: minWidth, height: minHeight),
        CGRect(x: maxWidth + spacing, y: minHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: 0, y: maxHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: maxHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth * 2 + spacing * 2, y: maxHeight + spacing, width: minWidth, height: minHeight)
      ]
    case .topRight:
      return [
        CGRect(x: 0, y: 0, width: minWidth, height: minWidth),
        CGRect(x: 0, y: minWidth + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: 0, width: maxWidth, height: maxHeight),
        CGRect(x: 0, y: maxHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: maxHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth * 2 + spacing * 2, y: maxHeight + spacing, width: minWidth, height: minHeight)
      ]
    case .bottomLeft:
      return [
        CGRect(x: 0, y: 0, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: 0, width: minWidth, height: minHeight),
        CGRect(x: maxWidth + spacing, y: 0, width: minWidth, height: minHeight),
        CGRect(x: 0, y: minHeight + spacing, width: maxWidth, height: maxHeight),
        CGRect(x: maxWidth + spacing, y: minHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: maxWidth + spacing, y: maxHeight + spacing, width: minWidth, height: minHeight)
      ]
    case .bottomRight:
      return [
        CGRect(x: 0, y: 0, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: 0, width: minWidth, height: minHeight),
        CGRect(x: maxWidth + spacing, y: 0, width: minWidth, height: minHeight),
        CGRect(x: 0, y: minHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: 0, y: maxHeight + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: minHeight + spacing, width: maxWidth, height: maxHeight),
      ]
    case .layout1:
      return [
        CGRect(x: 0, y: 0, width: side, height: side),
        CGRect(x: 0, y: side + spacing, width: minWidth, height: minHeight),
        CGRect(x: minWidth + spacing, y: side + spacing, width: minWidth, height: minHeight),
        CGRect(x: maxWidth + spacing, y: side + spacing, width: minWidth, height: minHeight),
        CGRect(x: 0, y: side + spacing + minHeight + spacing, width: maxWidth, height: maxHeight),
        CGRect(x: maxWidth + spacing, y: side + spacing + minHeight + spacing, width: minWidth, height: maxHeight)
      ]
    }
  }
}
