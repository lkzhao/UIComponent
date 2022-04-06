//  Created by y H on 2022/4/5.

import CoreGraphics

enum GridFlowDimension {
  case cross
  case main
}

struct GridIndex: Equatable, Hashable {
  var column: Int
  var row: Int

  static let zero = GridIndex(column: 0, row: 0)
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
  
  func isOccupy(flow: GridFlow) -> Bool {
    endIndex[keyPath: flow.index(.main)] - startIndex[keyPath: flow.index(.main)] > 0
  }

  func contains(_ index: GridIndex) -> Bool {
    return index.column >= startIndex.column
      && index.column <= endIndex.column
      && index.row >= startIndex.row
      && index.row <= endIndex.row
  }
}


extension Array where Element == Component {
  func transformGridSpan(flow: GridFlow, fixedTrackCount: Int) -> [GridSpan] {
    map { component -> GridSpan in
      if let gridSpan = component as? GridSpan {
        if gridSpan[keyPath: flow.spanIndex(.cross)] > fixedTrackCount {
          let fixedTrack = fixedTrackCount
          print("fixedTrack: \(gridSpan[keyPath: flow.spanIndex(.cross)]) 超出Track最大值, 重设后: \(fixedTrack) ")
          var span = GridSpan(child: gridSpan.child)
          span[keyPath: flow.spanIndex(.main)] = gridSpan[keyPath: flow.spanIndex(.main)]
          span[keyPath: flow.spanIndex(.cross)] = fixedTrack
          return span
        }
        return gridSpan
      }
      return GridSpan(child: component)
    }
  }
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
    var fixedIndex = self[keyPath: flow.index(.cross)]
    var growingIndex = self[keyPath: flow.index(.main)]
    let fixedSpan = span[keyPath: flow.spanIndex(.cross)]
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
    nextIndex[keyPath: flow.index(.cross)] = fixedIndex
    nextIndex[keyPath: flow.index(.main)] = growingIndex
    return nextIndex
  }
}

internal extension GridFlow {
  func index(_ dimension: GridFlowDimension) -> WritableKeyPath<GridIndex, Int> {
    switch dimension {
    case .cross:
      return (self == .rows ? \GridIndex.column : \GridIndex.row)
    case .main:
      return (self == .columns ? \GridIndex.column : \GridIndex.row)
    }
  }

  func spanIndex(_ dimension: GridFlowDimension) -> WritableKeyPath<GridSpan, Int> {
    switch dimension {
    case .cross:
      return (self == .rows ? \GridSpan.column : \GridSpan.row)
    case .main:
      return (self == .columns ? \GridSpan.column : \GridSpan.row)
    }
  }
}

internal extension CGFloat {
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
