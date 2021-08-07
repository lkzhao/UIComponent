//  Created by y H on 2021/7/29.

import UIKit
import UIComponent

struct GalleryItemData: Equatable {
  let id = UUID().uuidString
  let cover: URL = randomWebImage()
}

struct GalleryItem: ComponentBuilder {
  let data: GalleryItemData
  func build() -> Component {
    AsyncImage(data.cover, indicatorType: .activity, options: [.transition(.flipFromBottom(0.35))])
      .contentMode(.scaleAspectFill)
      .clipsToBounds(true)
      .id(data.id)
  }
}

struct GalleryIndexOverlay: ComponentBuilder {
  let index: Int
  func build() -> Component {
    Text("\(index)").textColor(.white).textAlignment(.center)
  }
}

struct GalleryFrames: GalleryTemplate {
  
  enum LayoutType: CaseIterable {
    case layout1, layout2, layout3
  }
  
  let layout: LayoutType
  
  func calculateFrames(spacing: CGFloat, side: CGFloat, makeFrame: (Point, Size) -> CGRect) -> [CGRect] {
    let mini = (side - (spacing * 2)) / 3.0
    let medium = mini * 2 + spacing
    let large = side
    
    switch layout {
    case .layout1:
      return [
        makeFrame((main: 0, cross: 0), (main: large, cross: large)),
        makeFrame((main: large + spacing, cross: 0), (main: mini, cross: large)),
        makeFrame((main: large + mini + spacing * 2, cross: 0), (main: medium, medium)),
        makeFrame((main: large + mini + spacing * 2, cross: medium + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + mini + mini + spacing * 3, cross: medium + spacing), (main: mini, cross: mini))
      ]
    case .layout2:
      return [
        makeFrame((main: 0, cross: 0), (main: large, cross: large)),
        makeFrame((main: large + spacing, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + spacing, cross: mini + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + spacing, cross: mini * 2 + spacing * 2), (main: mini, cross: mini)),
        makeFrame((main: large + mini + spacing * 2, cross: 0), (main: medium, cross: medium)),
        makeFrame((main: large + mini + spacing * 2, cross: medium + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + medium + spacing * 2, cross: medium + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: mini + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: medium + spacing), (main: mini, cross: mini))
      ]
    case .layout3:
      return [
        makeFrame((main: 0, cross: 0), (main: large, cross: large)),
        makeFrame((main: large + spacing, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + spacing, cross: mini + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + spacing, cross: mini * 2 + spacing * 2), (main: mini, cross: mini)),
        makeFrame((main: large + mini + spacing * 2, cross: mini + spacing), (main: medium, cross: medium)),
        makeFrame((main: large + mini + spacing * 2, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + medium + spacing * 2, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: 0), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: mini + spacing), (main: mini, cross: mini)),
        makeFrame((main: large + medium + mini + spacing * 3, cross: medium + spacing), (main: mini, cross: mini))
      ]
    }
  }
}

