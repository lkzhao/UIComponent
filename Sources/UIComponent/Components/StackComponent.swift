//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct HStack: StackComponent, HorizontalLayoutProtocol {
  public var wrapper: Wrapper
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
  public init(spacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              wrapper: Wrapper = .noWrap,
              children: [Component] = []) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.wrapper = wrapper
    self.children = children
  }
}

public struct VStack: StackComponent, VerticalLayoutProtocol {
  public var wrapper: Wrapper
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
  public init(spacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              wrapper: Wrapper = .noWrap,
              children: [Component] = []) {
    self.spacing = spacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.wrapper = wrapper
    self.children = children
  }
}

public extension HStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, wrapper: Wrapper = .noWrap, @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              wrapper: wrapper,
              children: content())
  }
}

public extension VStack {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, wrapper: Wrapper = .noWrap, @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              wrapper: wrapper,
              children: content())
  }
}

public protocol StackComponent: Component, BaseLayoutProtocol {
  var spacing: CGFloat { get }
  var justifyContent: MainAxisAlignment { get }
  var alignItems: CrossAxisAlignment { get }
  var children: [Component] { get }
  var wrapper : Wrapper { get }
}

extension StackComponent {
  public func layout(_ constraint: Constraint) -> Renderer {
    
    func frame(child: Renderer, primaryCross: CGFloat, primaryOffset: CGFloat) -> (CGPoint, CGSize) {
         (point(main: primaryOffset, cross: primaryCross), child.size)
    }
    func maxSize(_ l: (CGPoint, CGSize), _ r: (CGPoint, CGSize)) -> (CGPoint, CGSize) {
        if cross(l.1) > cross(r.1) {
            return l
        } else {
            return r
        }
    }
    
    var renderers = getRenderers(constraint)
    let mainTotal = renderers.reduce(0) {
      $0 + main($1.size)
    }
    
    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: main(constraint.maxSize),
                                                               totalPrimary: mainTotal,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: renderers.count)
    var rowFrames = [[(point: CGPoint, size: CGSize)]]()
    let crossMax: CGFloat
    if wrapper == .wrap {
        var primaryOffset = offset
        var primaryCross: CGFloat = 0
        
        var leftMain: CGFloat = main(constraint.maxSize) - offset
        
        var tempFrames = [(point: CGPoint, size: CGSize)]()
        
        for (index, child) in renderers.enumerated() {
            if (main(child.size) + distributedSpacing) > leftMain {
                let max = tempFrames.reduce((CGPoint.zero, CGSize.zero), { maxSize($0, $1) })
                primaryCross += (distributedSpacing + cross(max.1))
                rowFrames.append(tempFrames)
                // reset
                tempFrames = []
                primaryOffset = offset
                leftMain = main(constraint.maxSize) - offset
            }
            tempFrames.append(frame(child: child, primaryCross: primaryCross, primaryOffset: primaryOffset))
            primaryOffset += main(child.size) + distributedSpacing
            leftMain = (main(constraint.maxSize) - offset) - primaryOffset
            if index == renderers.count - 1 {
                rowFrames.append(tempFrames)
                tempFrames = []
            }
        }
        
        crossMax = rowFrames.reduce(CGFloat(0)) { result, frames in
            let rowMaxCross = frames.reduce(CGFloat(0), { max($0, cross($1.size))})
            return result + distributedSpacing + rowMaxCross
        } - distributedSpacing // remove last spacing
    } else {
        crossMax = renderers.reduce(CGFloat(0).clamp(cross(constraint.minSize), cross(constraint.maxSize))) {
            max($0, cross($1.size))
        }
    }
    if cross(constraint.maxSize) == .infinity, alignItems == .stretch {
      // when using alignItem = .stretch, we need to relayout child to stretch its cross axis
      renderers = getRenderers(Constraint(minSize: constraint.minSize,
                                          maxSize: size(main: main(constraint.maxSize), cross: crossMax)))
    }
    
    
    var primaryOffset = offset
    var positions: [CGPoint] = []
    
    for child in renderers {
      var crossValue: CGFloat
      switch alignItems {
      case .start:
        crossValue = 0
      case .end:
        crossValue = crossMax - cross(child.size)
      case .center:
        crossValue = (crossMax - cross(child.size)) / 2
      case .stretch:
        crossValue = 0
      }
      if wrapper == .noWrap {
        positions.append(point(main: primaryOffset, cross: crossValue))
      }
      primaryOffset += main(child.size) + distributedSpacing
    }
    
    let mainMax = rowFrames.reduce(CGFloat(0)) {
        max($0, $1.reduce(CGFloat(0), { $0 + main($1.size) + distributedSpacing }))
    }
    if wrapper == .wrap {
        // Align each row
        let tempFrame = rowFrames
        for (row, frames) in tempFrame.enumerated() {
            let maxCurrenRowCrossSize = frames.reduce(CGFloat(0), { max($0, cross($1.size)) })
            let maxTotalRowMainSize = frames.reduce(CGFloat(0), { $0 + main($1.size) })
            var adjustFrames = frames
            if justifyContent == .end {
                let offset = main(constraint.maxSize) - (maxTotalRowMainSize + (distributedSpacing * CGFloat(frames.count - 1)))
                adjustFrames = adjustFrames.map { frame -> (CGPoint, CGSize) in
                    return (point(main: offset + main(frame.point), cross: cross(frame.point)), frame.size)
                }
            } else if justifyContent == .center {
                let leftOverPrimary = main(constraint.maxSize) - maxTotalRowMainSize
                let offset = (leftOverPrimary - distributedSpacing * CGFloat(frames.count - 1)) / 2
                adjustFrames = adjustFrames.map { frame -> (CGPoint, CGSize) in
                    return (point(main: offset + main(frame.point), cross: cross(frame.point)), frame.size)
                }
            } else if justifyContent == .spaceBetween {
                let leftOverPrimary = main(constraint.maxSize) - maxTotalRowMainSize
                guard frames.count > 1 else { break }
                let spacing = leftOverPrimary / CGFloat(frames.count - 1)
                adjustFrames = adjustFrames.enumerated().map { (index, frame) -> (CGPoint, CGSize) in
                    // clear spacing
                    var main = main(frame.point) - (distributedSpacing * CGFloat(index))
                    // added new spacing
                    main += CGFloat(index) * spacing
                    return (point(main: main, cross: cross(frame.point)), frame.size)
                }
            } else if justifyContent == .spaceEvenly {
                let leftOverPrimary = main(constraint.maxSize) - maxTotalRowMainSize
                let spacing = leftOverPrimary / CGFloat(frames.count+1)
                adjustFrames = adjustFrames.enumerated().map { (index, frame) -> (CGPoint, CGSize) in
                    // clear spacing
                    var main = main(frame.point) - (distributedSpacing * CGFloat(index))
                    // added new spacing
                    main += CGFloat(index+1) * spacing
                    return (point(main: main, cross: cross(frame.point)), frame.size)
                }
            } else if justifyContent == .spaceAround {
                let leftOverPrimary = main(constraint.maxSize) - maxTotalRowMainSize
                let spacing = leftOverPrimary / CGFloat(frames.count)
                adjustFrames = adjustFrames.enumerated().map { (index, frame) -> (CGPoint, CGSize) in
                    // clear spacing
                    var main = main(frame.point) - (distributedSpacing * CGFloat(index))
                    // added new spacing
                    if index == 0 {
                        main += spacing/2
                    } else {
                        main += (CGFloat(index) * spacing) + (spacing/2)
                    }
                    return (point(main: main, cross: cross(frame.point)), frame.size)
                }
            }
            if alignItems == .end {
                adjustFrames = adjustFrames.map { frame -> (CGPoint, CGSize) in
                    return (point(main: main(frame.point), cross: (maxCurrenRowCrossSize - cross(frame.size)) + cross(frame.point)), frame.size)
                }
            } else if alignItems == .center {
                adjustFrames = adjustFrames.map { frame -> (CGPoint, CGSize) in
                    return (point(main: main(frame.point), cross: ((maxCurrenRowCrossSize - cross(frame.size)) / 2) + cross(frame.point)), frame.size)
                }
            }
            rowFrames[row] = adjustFrames
        }
    }
    let intrisicMain = wrapper == .noWrap ? primaryOffset : mainMax - distributedSpacing
    let finalMain = justifyContent != .start && main(constraint.maxSize) != .infinity ? max(main(constraint.maxSize), intrisicMain) : intrisicMain
    let finalSize = size(main: finalMain, cross: crossMax)

    return renderer(size: finalSize, children: renderers, positions: wrapper == .wrap ? rowFrames.reduce([CGPoint](), { $0 + $1.map{$0.point} }) : positions)
  }
  
  func getRenderers(_ constraint: Constraint) -> [Renderer] {
    var renderers: [Renderer?] = []
    let spacings = spacing * CGFloat(children.count - 1)
    var mainFreezed: CGFloat = spacings
    var flexCount: CGFloat = 0
    let crossMaxConstraint = cross(constraint.maxSize)

    var maxMain: CGFloat = .infinity
    if wrapper == .wrap {
        maxMain = main(constraint.maxSize)
    }
    let childConstraint = Constraint(minSize: size(main: -.infinity, cross: alignItems == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0),
                                     maxSize: size(main:  maxMain, cross: cross(constraint.maxSize)))
    for child in children {
      if let flexChild = child as? Flexible {
        flexCount += flexChild.flex
        renderers.append(nil)
      } else {
        let childRenderer = child.layout(childConstraint)
        mainFreezed += main(childRenderer.size)
        renderers.append(childRenderer)
      }
    }
    
    if flexCount > 0 {
      let mainMax = main(constraint.maxSize)
      let mainPerFlex = mainMax == .infinity ? 0 : max(0, mainMax - mainFreezed) / flexCount
      for (index, child) in children.enumerated() {
        if let child = child as? Flexible {
          let mainReserved = mainPerFlex * child.flex
          let constraint = Constraint(minSize: size(main: child.fit == .tight ? mainReserved : 0,
                                                    cross: alignItems == .stretch ? cross(constraint.maxSize) : 0),
                                      maxSize: size(main: mainReserved, cross: cross(constraint.maxSize)))
          let renderer = child.layout(constraint)
          if child.fit == .loose {
            renderers[index] = SizeOverrideRenderer(child: renderer, size: size(main: mainReserved, cross: cross(renderer.size)))
          } else {
            renderers[index] = renderer
          }
          mainFreezed += mainReserved
        }
      }
    }

    return renderers.map { $0! }
  }
}
