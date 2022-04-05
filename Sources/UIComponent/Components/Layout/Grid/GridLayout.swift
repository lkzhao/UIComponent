//  Created by y H on 2022/4/2.

import BaseToolbox
import CoreGraphics
import Foundation

enum GridFlowDimension {
  case fixed
  case growing
}

public protocol GridLayout: Component, BaseLayoutProtocol {
  var mainSpacing: CGFloat { get }
  var flow: GridFlow { get }
  var crossSpacing: CGFloat { get }
  var tracks: [GridTrack] { get }
  var children: [Component] { get }

  init(tracks: [GridTrack],
       flow: GridFlow,
       mainSpacing: CGFloat,
       crossSpacing: CGFloat,
       children: [Component])
}

public extension GridLayout {
  init(tracks: [GridTrack],
       flow: GridFlow,
       mainSpacing: CGFloat = 0,
       crossSpacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              flow: flow,
              mainSpacing: mainSpacing,
              crossSpacing: crossSpacing,
              children: content())
  }

  init(tracks: [GridTrack],
       flow: GridFlow = .rows,
       spacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    self.init(tracks: tracks,
              flow: flow,
              mainSpacing: spacing,
              crossSpacing: spacing,
              children: content())
  }

  init(tracks: Int,
       flow: GridFlow = .rows,
       spacing: CGFloat = 0,
       @ComponentArrayBuilder _ content: () -> [Component])
  {
    let tracks = (0..<tracks).map { _ in
      GridTrack.fr(1)
    }
    self.init(tracks: tracks,
              flow: flow,
              mainSpacing: spacing,
              crossSpacing: spacing,
              children: content())
  }
}

struct GridItemInfo {
  var bounds: CGRect
  let child: GridSpan
  let startIndex: GridIndex
  let endIndex: GridIndex
  var area: Int { rowsCount * columnsCount }
  var columnsCount: Int { endIndex.column - startIndex.column + 1 }
  var rowsCount: Int { endIndex.row - startIndex.row + 1 }

  init(bounds: CGRect, child: GridSpan, startIndex: GridIndex) {
    let endRow: Int = startIndex.row + child.row - 1
    let endColumn: Int = startIndex.column + child.column - 1
    self.bounds = bounds
    self.startIndex = startIndex
    self.endIndex = GridIndex(column: endColumn, row: endRow)
    self.child = child
  }

  func contains(_ index: GridIndex) -> Bool {
    return index.column >= startIndex.column
      && index.column <= endIndex.column
      && index.row >= startIndex.row
      && index.row <= endIndex.row
  }
}

struct GridIndex: Equatable, Hashable {
  var column: Int
  var row: Int

  static let zero = GridIndex(column: 0, row: 0)
}

public extension GridLayout {
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

  func layout(_ constraint: Constraint) -> RenderNode {
    let trackSizes = tracks.map { calculateTrackCrossSize(track: $0, constraint: constraint) }

    /// 获取轨道交叉轴大小
    /// - Parameters:
    ///   - trackOffset: 当前轨道的下标
    ///   - column: 当前轨道占用的column
    /// - Returns: ...
    func calculateTrackCrossWithFixedSize(trackOffset: Int, fixed: Int) -> CGFloat {
      // column - 1
      // 因为column是从1开始的
      let newColumn = max(0, fixed - 1)
      var totalMainSize: CGFloat = 0
      for offset in 0 ... newColumn {
        let newOffset = trackOffset + offset
        let trackMainSize = trackSizes[newOffset]
        totalMainSize += trackMainSize
      }
      return totalMainSize + (CGFloat(newColumn) * crossSpacing)
    }

    let gridSpans = children.map { component -> GridSpan in
      if let gridSpan = component as? GridSpan {
        if gridSpan[keyPath: flow.spanIndex(.fixed)] > tracks.count {
          let fixedTrack = tracks.count
          print("fixedTrack: \(gridSpan[keyPath: flow.spanIndex(.fixed)]) 超出Track最大值, 重设后: \(fixedTrack) ")
          var span = GridSpan(child: gridSpan.child)
          span[keyPath: flow.spanIndex(.growing)] = gridSpan[keyPath: flow.spanIndex(.growing)]
          span[keyPath: flow.spanIndex(.fixed)] = fixedTrack
          return span
        }
        return gridSpan
      }
      return GridSpan(child: component)
    }

    var coordinates = gridSpans.transformAbstractCoordinates(fixedTracksCount: tracks.count, flow: flow)
    var previousGrowingIndex: Int = 0
    var maxMainSizeInGrowing: CGFloat = 0
    var previousItem: GridItemInfo?
    
    // Update specific coordinates
    for data in coordinates.enumerated() {
      var item = data.element

      if previousGrowingIndex != item.startIndex[keyPath: flow.index(.growing)] {
        let rowItemsMainGrowingMaxSize = coordinates.filter { $0.startIndex[keyPath: flow.index(.growing)] == previousGrowingIndex }
          .map { main($0.bounds.origin) + main($0.bounds.size) }
          .reduce(0) { max($0, $1) }
        previousGrowingIndex = item.startIndex[keyPath: flow.index(.growing)]
        maxMainSizeInGrowing = rowItemsMainGrowingMaxSize
      }

      let crossSize = calculateTrackCrossWithFixedSize(trackOffset: item.startIndex[keyPath: flow.index(.fixed)], fixed: item.child[keyPath: flow.spanIndex(.fixed)])
      let mainSize = item.child.layout(.tight(size(main: .infinity, cross: crossSize))).size.height.meaningless(replace: crossSize)
      let crossPosition: CGFloat
      if let previousItem = previousItem {
        if previousItem.startIndex[keyPath: flow.index(.growing)] == item.startIndex[keyPath: flow.index(.growing)] {
          crossPosition = cross(previousItem.bounds.origin) + cross(previousItem.bounds.size) + crossSpacing
        } else {
          crossPosition = 0
        }
      } else {
        crossPosition = 0
      }
      item.bounds = CGRect(origin: point(main: maxMainSizeInGrowing == 0 ? maxMainSizeInGrowing : maxMainSizeInGrowing + mainSpacing, cross: crossPosition),
                           size: size(main: mainSize, cross: crossSize))
      coordinates[data.offset] = item
      previousItem = item
    }

    let renderNodes = coordinates.map {
      wrapperSizeComponnet(gridSpan: $0.child, size: $0.bounds.size, isDebug: false)
        .layout(.tight($0.bounds.size))
    }
    let allBounds = coordinates.map(\.bounds)
    let positions = allBounds.map(\.origin)
    let maxMian = allBounds.reduce(0) {
      max($0, main($1.size) + main($1.origin))
    }
    let maxCross = allBounds.reduce(0) {
      max($0, cross($1.size) + cross($1.origin))
    }
    return renderNode(size: size(main: maxMian, cross: maxCross), children: renderNodes, positions: positions)
  }

  private func wrapperSizeComponnet(gridSpan: GridSpan, size: CGSize, isDebug: Bool) -> Component {
    gridSpan.size(size).if(isDebug) {
      $0.overlay(Text("column: \(gridSpan.column)\nrow: \(gridSpan.row)")
        .textColor(.white)
        .textAlignment(.center)
        .fill()
        .background(SimpleViewComponent().backgroundColor(.black.withAlphaComponent(0.3))))
    }
  }
}

private extension CGFloat {
  func meaningless(replace: CGFloat) -> CGFloat {
    if self == .infinity || self <= 0 {
      return replace
    }
    return self
  }
}

private extension Int {
  var cgFloat: CGFloat { CGFloat(self) }
}

extension Array where Element == GridSpan {
  func transformAbstractCoordinates(fixedTracksCount: Int, flow: GridFlow) -> [GridItemInfo] {
    var result: [GridItemInfo] = []
    var lastIndex: GridIndex = .zero
    var occupiedIndices: [GridIndex] = []

    for spanPreference in self {
      var currentIndex: GridIndex = lastIndex
      while occupiedIndices.contains(currentIndex, span: spanPreference) {
        currentIndex = currentIndex.nextIndex(fixedTracksCount: fixedTracksCount,
                                              flow: flow,
                                              span: spanPreference)
      }
      occupiedIndices.appendPointsFrom(index: currentIndex, span: spanPreference)
      let gridItemInfo = GridItemInfo(bounds: .zero, child: spanPreference, startIndex: currentIndex)
      result.append(gridItemInfo)
      lastIndex = currentIndex
    }
    return result
  }
}

private extension Array where Element == GridIndex {
  func contains(_ startIndex: GridIndex, span: GridSpan) -> Bool {
    for row in startIndex.row..<startIndex.row + span.row {
      for column in startIndex.column..<startIndex.column + span.column {
        if contains(GridIndex(column: column, row: row)) {
          return true
        }
      }
    }
    return false
  }

  mutating func appendPointsFrom(index: GridIndex, span: GridSpan) {
    for row in index.row..<index.row + span.row {
      for column in index.column..<index.column + span.column {
        append(GridIndex(column: column, row: row))
      }
    }
  }
}

private extension GridIndex {
  func nextIndex(fixedTracksCount: Int, flow: GridFlow, span: GridSpan) -> GridIndex {
    var fixedIndex = self[keyPath: flow.index(.fixed)] // flow == .rows ? column : row
    var growingIndex = self[keyPath: flow.index(.growing)] // flow == .rows ? row : column
    let fixedSpan = span[keyPath: flow.spanIndex(.fixed)] // flow == .rows ? span.column : span.row
    func outerIncrementer() {
      fixedIndex += 1
    }
    func nextTrackTrigger() -> Bool {
      return fixedIndex + fixedSpan > fixedTracksCount
    }
    func innerIncrementer() {
      fixedIndex = 0
      growingIndex += 1
    }
    outerIncrementer()
    if nextTrackTrigger() {
      innerIncrementer()
    }
    var nextIndex = GridIndex.zero
    nextIndex[keyPath: flow.index(.fixed)] = fixedIndex
    nextIndex[keyPath: flow.index(.growing)] = growingIndex
    return nextIndex
  }
}

extension GridFlow {
  func index(_ dimension: GridFlowDimension) -> WritableKeyPath<GridIndex, Int> {
    switch dimension {
    case .fixed:
      return (self == .rows ? \GridIndex.column : \GridIndex.row)
    case .growing:
      return (self == .columns ? \GridIndex.column : \GridIndex.row)
    }
  }

  func spanIndex(_ dimension: GridFlowDimension) -> WritableKeyPath<GridSpan, Int> {
    switch dimension {
    case .fixed:
      return (self == .rows ? \GridSpan.column : \GridSpan.row)
    case .growing:
      return (self == .columns ? \GridSpan.column : \GridSpan.row)
    }
  }
}
