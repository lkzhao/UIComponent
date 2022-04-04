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
  let items: [GridItemInfo]
}

struct GridItemInfo {
  var bounds: CGRect
  var occupiedRowOfNumberLeast: Int?
  var trackOffset: Int
  let child: GridSpan
  var renderNode: RenderNode
  let offset: Int
  var isRowOccupied: Bool {
    if let occupiedRowOfNumberLeast = occupiedRowOfNumberLeast {
      return occupiedRowOfNumberLeast > 0
    } else {
      return false
    }
  }
}

extension GridLayout {
  func trackCrossSize(trackOffset: Int, column: Int, constraint: Constraint) -> CGFloat {
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
  
  private func calculateTrackCrossSize(track: GridTrack, constraint: Constraint) -> CGFloat {
    if case .pt(let value) = track {
      return min(cross(constraint.maxSize), value)
    }
    var cross = cross(constraint.maxSize)
    cross -= CGFloat(tracks.count - 1) * crossSpacing
    cross -= tracks.compactMap { track -> CGFloat? in
      if !track.isFlexible {
        return calculateTrackCrossSize(track: track, constraint: constraint)
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
  
  /// 计算track crossSIZE
  /// - Parameters:
  ///   - offset: track下标
  ///   - column: 占用多少个track
  ///   - constraint: -
  /// - Returns: TrackCrossSize + column
  private func calculateTrackCrossSize(offset: Int, column: Int, constraint: Constraint) -> CGFloat {
    assert(column >= 1)
    assert(column <= tracks.count - offset)
    var crossSize: CGFloat = 0.0
    for index in 0 ..< column {
      let trackOffset = offset + index
      let track = tracks[trackOffset]
      let trackCrossSize = calculateTrackCrossSize(track: track, constraint: constraint)
      crossSize += trackCrossSize + crossSpacing
    }
    return crossSize
  }
  
  public func layout(_ constraint: Constraint) -> RenderNode {
    let crossMax = cross(constraint.maxSize)
    let gridSpans = children.map { component -> GridSpan in
      if let gridSpan = component as? GridSpan {
        if gridSpan.column > tracks.count {
          let column = tracks.count
          print("column: \(gridSpan.column) 超出轨道最大值, 重设后: \(column) ")
          return GridSpan(column: column, row: gridSpan.row, child: gridSpan.child)
        }
        return gridSpan
      }
      return GridSpan(child: component)
    }
    
    // 必要数据
    var totalMainSize: CGFloat = 0
    var renderNodes: [RenderNode] = []
    var positions: [CGPoint] = []
    var pointCross: CGFloat = 0
    
    // 上下文信息
    /// 上一行中的信息（主要判断上一行是否有row占用的情况）
    var previousLineTrackInfo: GridTracksInfo?
    /// 一行中所有的items
    var columnItems = [GridItemInfo]()
    /// 当前轨道下标
    var trackOffset = 0
    /// 当一行中有剩余轨道，但是不足以放下，需要跳过，在新的一行中添加上。
    var skipColumnItem: GridItemInfo?
    /// 当前一行中所有占用轨道的items
    var currentLineOccupiedItems: [GridItemInfo] = []
    
    for data in gridSpans.enumerated() {
      // 如果一行有剩余轨道还放不下，需要强制换新一行。
      var isForceNewline = false
      // 这一行总共占用了多少条轨道
      var lineTotalColumn: Int { columnItems.map(\.child.column).reduce(0) { $0 + $1 } }
      // 计算出当前轨道的CrossSize，render需要添加CrossSize约束
      var trackCrossSize: CGFloat
      if (tracks.count - lineTotalColumn) >= data.element.column {
        trackCrossSize = calculateTrackCrossSize(offset: trackOffset, column: data.element.column, constraint: constraint)
      } else {
        trackCrossSize = calculateTrackCrossSize(offset: 0, column: data.element.column, constraint: constraint)
      }
      let renderNode = data.element.layout(Constraint(minSize: size(main: 0, cross: trackCrossSize), maxSize: size(main: .infinity, cross: trackCrossSize)))
      // 这里总是需要添加到renderNodes，保障后续对renderNode的mainSize更新
      renderNodes.append(renderNode)
      // 计算cross值, 这里需要说明的是offset: 0，是因为column值是对的就行，该方法会自动计算crossSize并加上crossSpacing
//      var pointCross = calculateTrackCrossSize(offset: 0, column: trackOffset + 1, constraint: constraint)
      
      // 判断是否有row占用, occupiedRowOfNumberLeast是还剩余多少行还没占用。。 这是一个自减过程，占用一行减少1。
      let occupiedRowOfNumberLeast: Int? = data.element.row > 1 ? data.element.row - 1 : nil
      
      // 当前行添加新的item
      func columnItemsAppend(gridItem: GridItemInfo) {
        // 这一行是否还放得下当前的column
        let isPutdown = (tracks.count - lineTotalColumn) >= gridItem.child.column
        // 判断是否放得下
        if isPutdown {
          columnItems.append(gridItem)
          positions.append(gridItem.bounds.origin)
          pointCross = cross(gridItem.bounds.origin) + cross(gridItem.bounds.size) + crossSpacing
        } else {
          // 放不下强制换新行，并标记跳过此行
          isForceNewline = true
          skipColumnItem = gridItem
        }
      }
      
      // 这里开始判断是否有上一行的消息
      if let previousLineTrackInfo = previousLineTrackInfo {
        // 有上一行的情况有点复杂。
        // 获取上一行最大Main
        let freezeMainSize = previousLineTrackInfo.items.reduce(0.0) {
          max($0, main($1.bounds.origin) + main($1.bounds.size))
        }
        // 检查上一行是否有row占用
        let occupiedItems = previousLineTrackInfo.items.filter(\.isRowOccupied)
        // 有占用
        if !occupiedItems.isEmpty, (tracks.count - lineTotalColumn) >= data.element.column {
          // 找到适合当前轨道占用的item
          // 添加上一行中要占用当前行轨道的items
          for var occupiedItem in occupiedItems {
            if let occupiedRowOfNumberLeast = occupiedItem.occupiedRowOfNumberLeast {
              occupiedItem.occupiedRowOfNumberLeast = occupiedRowOfNumberLeast - 1
            }
            columnItems.append(occupiedItem)
            currentLineOccupiedItems.append(occupiedItem)
          }
        }
        // 检查是否有上一次循环跳过的item
        if var skipItem = skipColumnItem {
          // 有跳过的话就增加到当前行
          skipItem.trackOffset = trackOffset
          skipItem.renderNode = skipItem.child.layout(Constraint(minSize: size(main: 0, cross: trackCrossSize), maxSize: size(main: .infinity, cross: trackCrossSize)))
          skipItem.bounds = CGRect(origin: point(main: freezeMainSize, cross: pointCross), size: size(main: main(skipItem.renderNode.size), cross: trackCrossSize))
          // 跳过的项目在新的一行中添加完毕，清空skipColumnItem
          skipColumnItem = nil
          renderNodes[skipItem.offset] = skipItem.renderNode
          columnItemsAppend(gridItem: skipItem)
          trackOffset += skipItem.child.column
          // 更新pointCross
          pointCross = calculateTrackCrossSize(offset: 0, column: trackOffset, constraint: constraint)
          // 判断添加完上一次跳过的item之后剩余的轨道数量依然能放进当前的轨道，否则的话只能继续跳过等待下一次循环添加进去。
          if ((tracks.count - 1) - trackOffset) >= data.element.column {
            trackCrossSize = calculateTrackCrossSize(offset: trackOffset, column: data.element.column, constraint: constraint)
          }
        }
        // 获取没有被占用的track
        var _tmp = 0
        var currentLineOccupiedTrackOffset: [Int] = []
        for offset in 0 ..< tracks.count {
          if currentLineOccupiedTrackOffset.contains(offset) {
            currentLineOccupiedTrackOffset.append(_tmp)
            _tmp = 0
          } else {
            _tmp += 1
          }
        }
        // 需要找到没有被占用的track
        
        currentLineOccupiedItems.map(\.trackOffset).contains(trackOffset)
        let gridItemInfo = GridItemInfo(bounds: CGRect(origin: point(main: freezeMainSize + mainSpacing, cross: pointCross),
                                                       size: size(main: main(renderNode.size), cross: trackCrossSize)),
                                        occupiedRowOfNumberLeast: occupiedRowOfNumberLeast,
                                        trackOffset: trackOffset,
                                        child: data.element,
                                        renderNode: renderNode,
                                        offset: data.offset)
        columnItemsAppend(gridItem: gridItemInfo)
        
        // 这里来更新占用的mainSize
        for var occupiedItem in currentLineOccupiedItems {
          let noOccupiedItems = columnItems.filter { currentLineOccupiedItems.map(\.offset).contains($0.offset) }
          if !noOccupiedItems.isEmpty {
            let maxMainSize = noOccupiedItems.reduce(0) {
              max($0, main($1.bounds.size))
            }
            let bounds = occupiedItem.bounds
            occupiedItem.bounds = CGRect(origin: bounds.origin, size: size(main: maxMainSize + mainSpacing, cross: cross(bounds.size)))
            renderNodes[occupiedItem.offset] = occupiedItem.child.layout(.tight(occupiedItem.bounds.size))
          }
        }
        
      } else {
        // 这里说明这是第一行。
        let gridItemInfo = GridItemInfo(bounds: CGRect(origin: point(main: 0, cross: pointCross),
                                                       size: size(main: main(renderNode.size), cross: trackCrossSize)),
                                        occupiedRowOfNumberLeast: occupiedRowOfNumberLeast,
                                        trackOffset: trackOffset,
                                        child: data.element,
                                        renderNode: renderNode,
                                        offset: data.offset)
        columnItemsAppend(gridItem: gridItemInfo)
      }
      
      // 判断新一行，强制换行，轨道全部占满换行，最后一个也要进入换行
      if isForceNewline || columnItems.map(\.child.column).reduce(0, { $0 + $1 }) == tracks.count || data.offset == (gridSpans.endIndex - 1) {
        // 新一行需要对items的mainSize进行统一，取最大值进行统一。还要筛选出去row占用的item
        // 如果上一行items中的offset和这一行中items的offset有重叠说明这一行有来自上一行的item需要去除。
        // 这里不能使用`isRowOccupied`属性来判断是否占用。因为有可能上一行占用到这一行就刚刚好不占用了，上面也说了occupiedRowOfNumberLeast是自减过程。
        // 去除之后找到mainSize最大的那个item出来，把其余item的mainSize都设置成最大的那个
        let noOccupiedRowItems = columnItems.filter { !(previousLineTrackInfo?.items.map(\.offset).contains($0.offset) ?? false) }
        let maxMainSize = noOccupiedRowItems.reduce(0) {
          max($0, main($1.bounds.size))
        }
        // 只需要更新renderNodes和columnItems就行。
        for var item in noOccupiedRowItems {
          var bounds = item.bounds
          bounds.size = size(main: maxMainSize, cross: cross(bounds.size))
          item.bounds = bounds
          renderNodes[item.offset] = item.child.layout(.tight(bounds.size))
          if let index = columnItems.firstIndex(where: { $0.offset == item.offset }) {
            columnItems[index] = item
          }
        }
        
        // 新一行, 重设trackOffset ...
        trackOffset = 0
        totalMainSize += maxMainSize + mainSpacing
        previousLineTrackInfo = .init(items: columnItems)
        pointCross = 0
        columnItems = []
        currentLineOccupiedItems = []
      } else {
        // 这里没有满足换行条件，trackOffset需要增加
        // 需要根据当前column来判断trackOffset
        trackOffset += data.element.column
        // 开始下一轮循环
      }
    }
    
    let totalSize = size(main: totalMainSize, cross: crossMax)
    
    return renderNode(size: totalSize, children: renderNodes, positions: positions)
  }
  
  /*
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
       guard tracks.count >= data.element.column else {
         print("当前Component的column大于tracks，将会忽略此Component，请检查！")
         continue
       }
       var isForceNewline = false
       let trackCrossSize = trackCrossSize(trackOffset: trackOffset, column: data.element.column, constraint: constraint)
       // 继续添加item
       let render = data.element.layout(Constraint(minSize: size(main: 0, cross: trackCrossSize), maxSize: size(main: .infinity, cross: trackCrossSize)))
       renderNodes.append(render)
       assert(main(render.size) != .infinity)
       var cross: CGFloat = 0
       if trackOffset != 0 {
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
         if var skipItem = skipColumnItem {
           let trackCrossSize = self.trackCrossSize(trackOffset: trackOffset, column: skipItem.child.column, constraint: constraint)
           let render = data.element.layout(Constraint(minSize: size(main: 0, cross: trackCrossSize), maxSize: size(main: .infinity, cross: trackCrossSize)))
           renderNodes[skipItem.offset] = render
           let bounds = CGRect(origin: point(main: freezeMainSize + mainSpacing, cross: cross), size: render.size)
           skipItem.bounds = bounds
           columnItems.append(skipItem)
           positions.append(bounds.origin)
           skipColumnItem = nil
           trackOffset += skipItem.child.column
         }
         // 保证最新的cross
         if trackOffset != 0 {
           // 无论是从哪条track上只要column对就好
           cross = self.trackCrossSize(trackOffset: 0, column: trackOffset, constraint: constraint) + crossSpacing
         }
         let bounds = CGRect(origin: point(main: freezeMainSize + mainSpacing, cross: cross), size: render.size)
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
         if !occupiedItems.isEmpty && (tracks.count - lineTotalColumn) >= data.element.column {
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
   */
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
