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

enum LayoutType: CaseIterable {
  case topLeft, topRight, bottomLeft, bottomRight, layout1, layout2
}

struct IrregularSimpleComponent: ComponentBuilder {
  let coverModels: [CoverModel]
  let type: LayoutType
  let spacing: CGFloat
  let showOrder: Bool
  
  init(coverModels: [CoverModel], type: LayoutType, spacing: CGFloat, showOrder: Bool = false) {
    self.coverModels = coverModels
    self.type = type
    self.spacing = spacing
    self.showOrder = showOrder
  }
  
  func build() -> Component {
    CustomizeLayout {
      for (index, item) in coverModels.enumerated() {
        AsyncImage(item.cover).contentMode(.scaleAspectFill).clipsToBounds(true).id(item.id).overlay(showOrder ? Text("\(index)").textColor(.white).textAlignment(.center).backgroundColor(UIColor.black.withAlphaComponent(0.5)) : Space())
      }
    } blockFrames: { constraint in
      return Array(genFrames(side: min(constraint.maxSize.width, constraint.maxSize.height), spacing: spacing, type: type).prefix(coverModels.count))
    }
  }
}

class IrregularCustomComponent: ComponentBuilder {
  
  private var freezeX: CGFloat = 0
  private var freezeY: CGFloat = 0
  
  let coverModels: [CoverModel]
  let isVertical: Bool
  let spacing: CGFloat
  let showOrder: Bool
  let configLayout: (_ index: Int) -> LayoutType
  
  init(coverModels: [CoverModel], isVertical: Bool = true, configLayout: @escaping (_ index: Int) -> LayoutType, spacing: CGFloat, showOrder: Bool = false) {
    self.coverModels = coverModels
    self.configLayout = configLayout
    self.spacing = spacing
    self.showOrder = showOrder
    self.isVertical = isVertical
  }
  
  func build() -> Component {
    CustomizeLayout {
      for (index, item) in coverModels.enumerated() {
        AsyncImage(item.cover).contentMode(.scaleAspectFill).clipsToBounds(true).id(item.id).overlay(showOrder ? Text("\(index)").textColor(.white).textAlignment(.center).backgroundColor(UIColor.black.withAlphaComponent(0.5)) : Space())
      }
    } blockFrames: { [unowned self] constraint in
      var allFrames = [CGRect]()
      var index = 0
      func appendFrames() {
        if allFrames.count < self.coverModels.count {
          let frames = genFrames(side: min(constraint.maxSize.width, constraint.maxSize.height),
                                 spacing: self.spacing,
                                 freezeX: self.isVertical ? 0 : self.freezeX,
                                 freezeY: self.isVertical ? self.freezeY : 0,
                                 type: self.configLayout(index))
          
          self.freezeX = frames.reduce(CGFloat(0), {
            max($0, $1.maxX)
          }) + spacing
          self.freezeY = frames.reduce(CGFloat(0), {
            max($0, $1.maxY)
          }) + spacing
          allFrames.append(contentsOf: frames)
          index += 1
          appendFrames()
        }
      }
      appendFrames()
      return Array(allFrames.prefix(coverModels.count))
    }
    
  }
}


private func genFrames(side: CGFloat, spacing: CGFloat, freezeX: CGFloat = 0, freezeY: CGFloat = 0, type: LayoutType) -> [CGRect] {
  let minWidth = (side - (spacing * 2)) / 3.0
  let maxWidth = (side - spacing) - minWidth
  let minHeight = minWidth
  let maxHeight = maxWidth
  
  switch type {
  case .topLeft:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: maxWidth, height: maxHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: minHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: (minWidth * 2 + spacing * 2) + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight)
    ]
  case .topRight:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: minWidth, height: minWidth),
      CGRect(x: 0 + freezeX, y: minWidth + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: 0 + freezeY, width: maxWidth, height: maxHeight),
      CGRect(x: 0 + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: (minWidth * 2 + spacing * 2) + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight)
    ]
  case .bottomLeft:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: minHeight + spacing + freezeY, width: maxWidth, height: maxHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: minHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight)
    ]
  case .bottomRight:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: 0 + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: minHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: maxHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: minHeight + spacing + freezeY, width: maxWidth, height: maxHeight),
    ]
  case .layout1:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: side, height: side),
      CGRect(x: 0 + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: side + spacing + minHeight + spacing + freezeY, width: maxWidth, height: maxHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: side + spacing + minHeight + spacing + freezeY, width: minWidth, height: maxHeight)
    ]
  case .layout2:
    return [
      CGRect(x: 0 + freezeX, y: 0 + freezeY, width: side, height: side),
      CGRect(x: 0 + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: minWidth + spacing + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: side + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: 0 + freezeX, y: side + spacing + minHeight + spacing + freezeY, width: maxWidth, height: maxHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: side + spacing + minHeight + spacing + freezeY, width: minWidth, height: minHeight),
      CGRect(x: maxWidth + spacing + freezeX, y: side + spacing + maxHeight + spacing + freezeY, width: minWidth, height: minHeight)
    ]
  }
}
