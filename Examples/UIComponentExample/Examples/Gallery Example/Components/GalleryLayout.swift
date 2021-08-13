//  Created by y H on 2021/7/30.

import UIKit
import UIComponent

protocol GalleryTemplate {
  typealias Point = (main: CGFloat, cross: CGFloat)
  typealias Size = Point
  func calculateFrames(spacing: CGFloat, side: CGFloat, makeFrame: (Point, Size) -> CGRect) -> [CGRect]
}

protocol GalleryLayout: Component, BaseLayoutProtocol {
  var spacing: CGFloat { get }
  var children: [Component] { get }
  var template: [GalleryTemplate] { get }
  init(spacing: CGFloat, template: [GalleryTemplate], children: [Component])
}

extension GalleryLayout {
  init(spacing: CGFloat = 0, template: [GalleryTemplate], @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing, template: template, children: content())
  }
}

extension GalleryLayout {
  
  func layout(_ constraint: Constraint) -> RenderNode {
    
    var allFrames = [CGRect]()
    var index = 0
    var freezeMain: CGFloat = 0
    func appendFrames() {
      if allFrames.count < self.children.count {
        if index >= template.count {
          index = 0
        }
        let frames = template[index].calculateFrames(spacing: spacing, side: cross(constraint.maxSize), makeFrame: { CGRect(origin: point(main: $0.main, cross: $0.cross), size: size(main: $1.main, cross: $1.cross)) }).map {
          CGRect(origin: point(main: main($0.origin) + freezeMain, cross: cross($0.origin)), size: size(main: main($0.size), cross: cross($0.size)))
        }
        freezeMain = frames.reduce(CGFloat(0), {
          max($0, main($1.origin) + main($1.size))
        }) + spacing
        allFrames += frames
        index += 1
        appendFrames()
      } else {
        allFrames = Array(allFrames.prefix(children.count))
      }
    }
    appendFrames()
    let finalFrame = allFrames.reduce(allFrames.first ?? .zero, { $0.union($1) })
    return renderNode(size: size(main: main(finalFrame.size), cross: cross(finalFrame.size)),
                      children: zip(children, allFrames).map({ $0.0.layout(.tight(size(main: main($0.1.size), cross: cross($0.1.size)))) }),
                      positions: allFrames.map({ point(main: main($0.origin), cross: cross($0.origin)) }))
  }
}

struct VerticalGallery: GalleryLayout, VerticalLayoutProtocol {
  var spacing: CGFloat
  var template: [GalleryTemplate]
  var children: [Component]
  
  init(spacing: CGFloat, template: [GalleryTemplate], children: [Component]) {
    self.spacing = spacing
    self.template = template
    self.children = children
  }
}

struct HorizontalGallery: GalleryLayout, HorizontalLayoutProtocol {
  var spacing: CGFloat
  var template: [GalleryTemplate]
  var children: [Component]
  
  init(spacing: CGFloat, template: [GalleryTemplate], children: [Component]) {
    self.spacing = spacing
    self.template = template
    self.children = children
  }
}
