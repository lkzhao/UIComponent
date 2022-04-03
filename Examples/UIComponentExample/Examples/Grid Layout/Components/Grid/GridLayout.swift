//  Created by y H on 2022/4/2.

import BaseToolbox
import CoreGraphics
import Foundation
import UIComponent

public struct Grid: GridLayout, VerticalLayoutProtocol {
  public var mainSpacing: CGFloat
  
  public var crossSpacing: CGFloat
  
  public var tracks: [GridTrack]
  
  public var children: [Component]
  
  public init(tracks: [GridTrack], mainSpacing: CGFloat, crossSpacing: CGFloat, children: [Component]) {
    self.tracks = tracks
    self.mainSpacing = mainSpacing
    self.crossSpacing = crossSpacing
    self.children = children
  }
}

public protocol GridLayout: Component, BaseLayoutProtocol {
  var mainSpacing: CGFloat { get }
  var crossSpacing: CGFloat { get }
  var tracks: [GridTrack] { get }
  var children: [Component] { get }

  init(tracks: [GridTrack],
       mainSpacing: CGFloat,
       crossSpacing: CGFloat,
       children: [Component])
}

public extension GridLayout {
  init(tracks: [GridTrack],
       mainSpacing: CGFloat = 0,
       crossSpacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              mainSpacing: mainSpacing,
              crossSpacing: crossSpacing,
              children: content())
  }

  init(tracks: [GridTrack],
       spacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              mainSpacing: spacing,
              crossSpacing: spacing,
              children: content())
  }
}

struct GridTracksInfo {
  let indexLine: Int
  let items: [GridItemInfo]
}

struct GridItemInfo {
  var bounds: CGRect
  var occupiedRowOfNumberLeast: Int?
  let trackOffset: Int
  let child: GridSpanComponent
  let renderNode: RenderNode
  let offset: Int
  var isRowOccupied: Bool {
    if let occupiedRowOfNumberLeast = occupiedRowOfNumberLeast {
      return occupiedRowOfNumberLeast > 0
    } else {
      return false
    }
  }
}

struct GridSpanLineContext {
  let spanContext: GridItemInfo
  let line: Int
}

public extension GridLayout {
  fileprivate func trackCrossSize(trackOffset: Int, column: Int, constraint: Constraint) -> CGFloat {
    func getTrackCrossSize(_ track: GridTrack) -> CGFloat {
      if case .pt(let value) = track {
        return min(cross(constraint.maxSize), value)
      }
      var cross = cross(constraint.maxSize)
      cross -= CGFloat(tracks.count - 1) * crossSpacing
      cross -= tracks.compactMap { track -> CGFloat? in
        if case .pt(let v) = track {
          return v
        }
        return nil
      }.reduce(0) {
        $0 + $1
      }
      let totalFrValue = tracks.compactMap { track -> CGFloat? in
        if case .fr(let v) = track {
          return v
        }
        return nil
      }.reduce(0) {
        $0 + $1
      }
      if case .fr(let value) = track {
        return (value / totalFrValue) * cross
      }
      fatalError()
    }
    
    let track = tracks[trackOffset]
    let legalColumn = min(tracks.count, column - 1)
    if case .pt(let value) = track {
      if legalColumn == 0 {
        return min(cross(constraint.maxSize), value)
      } else {
        var crossSize = value
        for index in 0 ... legalColumn {
          if let track = tracks[safe: index + trackOffset] {
            let trackCrossSize = getTrackCrossSize(track) + crossSpacing
            crossSize += trackCrossSize
          }
        }
        return crossSize
      }
    } else if case .fr = track {
      var crossSize = getTrackCrossSize(track)
      if legalColumn == 0 {
        return crossSize
      } else {
        for index in 1 ... legalColumn {
          if let track = tracks[safe: index + trackOffset] {
            let trackCrossSize = getTrackCrossSize(track) + crossSpacing
            crossSize += trackCrossSize
          }
        }
        return crossSize
      }
    } else {
      fatalError("Error track: \(track)")
    }
  }
  
  func layout(_ constraint: Constraint) -> RenderNode {
    let crossMax = cross(constraint.maxSize)
    let gridSpans = children.map { $0 as? GridSpanComponent ?? GridSpanComponent(child: $0) }
    var lineTrackInfos = [GridTracksInfo]()
    var previousLineTrackInfo: GridTracksInfo?
    var trackOffset = 0
    var lineOffset = 0
    var columnItems = [GridItemInfo]()
    var totalMainSize: CGFloat = 0.0
    var renderNodes = [RenderNode]()
    var positions = [CGPoint]()
    var skipColumnItem: GridItemInfo? = nil
    
    for data in gridSpans.enumerated() {
      var isForceNewline = false
      let trackCrossSize = trackCrossSize(trackOffset: trackOffset, column: data.element.column, constraint: constraint)
      // 继续添加item
      let render = data.element.layout(Constraint(minSize: size(main: 0, cross: trackCrossSize), maxSize: size(main: .infinity, cross: trackCrossSize)))
      renderNodes.append(render)
      assert(main(render.size) != .infinity)
      let cross: CGFloat
      if trackOffset == 0 {
        cross = 0
      } else {
        // 无论是从哪条track上只要column对就好
        cross = self.trackCrossSize(trackOffset: 0, column: trackOffset, constraint: constraint) + crossSpacing
      }
      
      let occupiedRowOfNumberLeast: Int?
      if data.element.row > 1 {
        occupiedRowOfNumberLeast = data.element.row - 1
      } else {
        occupiedRowOfNumberLeast = nil
      }
      
      // 如果有上一行，检查是否有row的占用
      if let previousLineTrackInfo = previousLineTrackInfo {
        let freezeMainSize = previousLineTrackInfo.items.reduce(0.0) {
          max($0, main($1.bounds.origin) + main($1.bounds.size))
        }
        // 添加上一行跳过的item
        if var skipColumnItem = skipColumnItem {
          let bounds = CGRect(origin: point(main: freezeMainSize + mainSpacing, cross: cross), size: skipColumnItem.renderNode.size)
          skipColumnItem.bounds = bounds
          columnItems.append(skipColumnItem)
          positions.append(bounds.origin)
          trackOffset += skipColumnItem.child.column
        }
        // 保证最新的cross
        let newCross = self.trackCrossSize(trackOffset: 0, column: trackOffset, constraint: constraint) + crossSpacing
        let bounds = CGRect(origin: point(main: freezeMainSize + mainSpacing, cross: newCross), size: render.size)
        // 添加当前行的item, 并判断当前行是否能放下
        let lineTotalColumn = columnItems.map(\.child.column).reduce(0) { $0 + $1 }
        let gridItemInfo = GridItemInfo(bounds: bounds,
                                        occupiedRowOfNumberLeast: occupiedRowOfNumberLeast,
                                        trackOffset: trackOffset,
                                        child: data.element,
                                        renderNode: render,
                                        offset: data.offset)
        if (tracks.count - lineTotalColumn) >= data.element.column {
          columnItems.append(gridItemInfo)
          positions.append(bounds.origin)
        } else {
          skipColumnItem = gridItemInfo
          isForceNewline = true
        }
        // 判断上一行是否有row占用
        let occupiedItems = previousLineTrackInfo.items.filter(\.isRowOccupied)
        // 有占用， 调整上一行占用row的mainSize
        if !occupiedItems.isEmpty {
          for occupiedItemData in occupiedItems.enumerated() {
            var occupiedItem = occupiedItemData.element
            if occupiedItem.trackOffset == trackOffset + 1 {
              let occupiedBounds = occupiedItem.bounds
              occupiedItem.bounds = CGRect(origin: occupiedBounds.origin, size: size(main: main(occupiedBounds.size) + mainSpacing + main(bounds.size), cross: self.cross(occupiedBounds.size)))
              renderNodes[occupiedItem.offset] = occupiedItem.child.layout(.tight(size(main: main(occupiedItem.bounds.size), cross: self.cross(occupiedItem.bounds.size))))
              if let occupiedRowOfNumberLeast = occupiedItem.occupiedRowOfNumberLeast {
                occupiedItem.occupiedRowOfNumberLeast = occupiedRowOfNumberLeast - 1
              }
              columnItems.append(occupiedItem)
            }
          }
        }
      } else {
        // 第一行
        let lineTotalColumn = columnItems.map(\.child.column).reduce(0) { $0 + $1 }
        let gridItemInfo = GridItemInfo(bounds: CGRect(origin: point(main: 0, cross: cross), size: size(main: main(render.size), cross: trackCrossSize)),
                                        occupiedRowOfNumberLeast: occupiedRowOfNumberLeast,
                                        trackOffset: trackOffset,
                                        child: data.element,
                                        renderNode: render,
                                        offset: data.offset)
        if (tracks.count - lineTotalColumn) >= data.element.column {
          columnItems.append(gridItemInfo)
          positions.append(point(main: 0, cross: cross))
        } else {
          skipColumnItem = gridItemInfo
          isForceNewline = true
        }
      }
      if isForceNewline || columnItems.map(\.child.column).reduce(0, { $0 + $1 }) == tracks.count || data.offset == (gridSpans.endIndex - 1) {
        // 下一行, 重设trackOffset
        trackOffset = 0
        
        let newColumnItems: [GridItemInfo]
        if let previousLineTrackInfo = previousLineTrackInfo {
          newColumnItems = columnItems.filter { !previousLineTrackInfo.items.map(\.offset).contains($0.offset) }
        } else {
          newColumnItems = columnItems
        }
        
        let maxMainSize = newColumnItems.reduce(0) {
          max($0, main($1.bounds.size))
        }
        for itemData in newColumnItems.enumerated() {
          var columnItem = itemData.element
          var bounds = columnItem.bounds
          bounds.size = size(main: maxMainSize, cross: self.cross(bounds.size))
          columnItem.bounds = bounds
          columnItems[itemData.offset] = columnItem
          renderNodes[columnItem.offset] = columnItem.child.layout(.tight(bounds.size))
        }
        
        // totalMainSize
        totalMainSize += maxMainSize
        
        // 添加数据
        lineTrackInfos.append(.init(indexLine: lineOffset, items: columnItems))
        
        previousLineTrackInfo = lineTrackInfos.last
        
        // 增加行数
        lineOffset += 1
        
        // 清除columnItems
        columnItems = []
      } else {
        // 需要根据当前column来判断trackOffset
        trackOffset += data.element.column
      }
    }
    
    let totalSize = size(main: totalMainSize, cross: crossMax)
    // positions 有问题（多了俩）标记一下先
    return renderNode(size: totalSize, children: renderNodes, positions: positions)
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
