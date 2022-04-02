//  Created by y H on 2022/4/2.

import CoreGraphics
import UIComponent
import BaseToolbox

public protocol GridLayout: Component, BaseLayoutProtocol {
  var mainSpacing: CGFloat { get }
  var crossSpacing: CGFloat { get }
  var tracks: Int { get }
  var children: [Component] { get }

  init(tracks: Int,
       mainSpacing: CGFloat,
       crossSpacing: CGFloat,
       children: [Component])
}

public extension GridLayout {
  init(tracks: Int,
       mainSpacing: CGFloat = 0,
       crossSpacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              mainSpacing: mainSpacing,
              crossSpacing: crossSpacing,
              children: content())
  }

  init(tracks: Int,
       spacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              mainSpacing: spacing,
              crossSpacing: spacing,
              children: content())
  }
}

struct GridSpanContext {
  let mainSize: CGFloat
  let crossSize: CGFloat
  let child: GridSpan
}

struct GridSpanLineContext {
  let spanContext: GridSpanContext
  let line: Int
}

public extension GridLayout {
  func layout(_ constraint: Constraint) -> RenderNode {
    
    let mainMax = main(constraint.maxSize)
    let crossMax = cross(constraint.maxSize)
    let childConstraint = Constraint(maxSize: size(main: .infinity, cross: crossMax))
    let gridSpans = children.map { $0 as? GridSpan ?? GridSpan(child: $0) }
    
    
    
    return renderNode(size: .zero, children: [], positions: [])
    
  }
}
