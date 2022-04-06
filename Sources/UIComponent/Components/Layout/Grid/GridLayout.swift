//  Created by y H on 2022/4/2.

import BaseToolbox
import CoreGraphics

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
       flow: GridFlow = .rows,
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
    let tracks = (0 ..< tracks).map { _ in
      GridTrack.fr(1)
    }
    self.init(tracks: tracks,
              flow: flow,
              mainSpacing: spacing,
              crossSpacing: spacing,
              children: content())
  }
}

public extension GridLayout {
  private func calculateTrackCrossSize(track: GridTrack, tracks: [GridTrack], constraint: Constraint) -> CGFloat {
    if case .pt(let value) = track {
      return min(cross(constraint.maxSize), value)
    }
    var cross = cross(constraint.maxSize)
    cross -= CGFloat(tracks.count - 1) * crossSpacing
    cross -= tracks.compactMap { track -> CGFloat? in
      if !track.isFlexible {
        return calculateTrackCrossSize(track: track, tracks: tracks, constraint: constraint)
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

  private func syncMainAxisSize(_ growingIndex: Int, coordinates: inout [GridItemInfo]) {
    let mainItems = coordinates.enumerated()
      .filter { $0.element.startIndex[keyPath: flow.index(.main)] == growingIndex }
    
    var growingMainAxisMaxSize = mainItems
      .filter { $0.element.child[keyPath: flow.spanIndex(.main)] <= 1 }
      .map(\.element).reduce(0) { max($0, main($1.bounds.size)) }
    if growingMainAxisMaxSize == 0 {
      growingMainAxisMaxSize = mainItems
        .map(\.element).reduce(CGFloat.infinity) { min($0, main($1.bounds.size)) }
    }
    mainItems.forEach { data in
      var _item = data.element
      _item.bounds.size = size(main: growingMainAxisMaxSize, cross: cross(_item.bounds.size))
      coordinates[data.offset] = _item
    }
  }
  
  private func updateOccupyMainAxis(coordinates: inout [GridItemInfo]) {
    let occupyItems = coordinates.enumerated().filter { $0.element.isOccupy(flow: flow) }.filter { data in
      let growingIndex = data.element.startIndex[keyPath: flow.index(.main)]
      let otherItems = coordinates.filter{ growingIndex == $0.startIndex[keyPath: flow.index(.main)] }
        .filter { $0.child[keyPath: flow.spanIndex(.main)] == 1 }
      return !otherItems.isEmpty
    }
    
    for data in occupyItems {
      let findOccpyEndTargets = coordinates.filter { $0.startIndex[keyPath: flow.index(.main)] == data.element.endIndex[keyPath: flow.index(.main)] }
      guard !findOccpyEndTargets.isEmpty else { continue }
      let occpyEndTargetsMaxMainBounds = findOccpyEndTargets.reduce(into: CGRect.zero) {
        $0 = main($1.bounds.size) > main($0.size) ? $1.bounds : $0
      }
      var item = data.element
      let difference = main(occpyEndTargetsMaxMainBounds.origin) - (main(data.element.bounds.origin) + main(data.element.bounds.size))
      item.bounds = CGRect(origin: item.bounds.origin, size: size(main: main(item.bounds.size) + difference + main(occpyEndTargetsMaxMainBounds.size), cross: cross(item.bounds.size)))
      coordinates[data.offset] = item
    }
  }

  /// 获取轨道大小
  /// - Parameters:
  ///   - trackOffset: 当前轨道的下标
  ///   - column: 当前轨道占用的column
  /// - Returns: ...
  private func calculateTrackCrossWithCrossSize(trackOffset: Int, crossOffset: Int, trackSizes: [CGFloat]) -> CGFloat {
    // column - 1
    // 因为column是从1开始的
    let newColumn = max(0, crossOffset - 1)
    var totalMainSize: CGFloat = 0
    for offset in 0 ... newColumn {
      let newOffset = trackOffset + offset
      let trackMainSize = trackSizes[newOffset]
      totalMainSize += trackMainSize
    }
    return totalMainSize + (CGFloat(newColumn) * crossSpacing)
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

  func layout(_ constraint: Constraint) -> RenderNode {
    let trackSizes = tracks.map { calculateTrackCrossSize(track: $0, tracks: tracks, constraint: constraint) }

    let gridSpans = children.transformGridSpan(flow: flow, fixedTrackCount: tracks.count)

    var coordinates = gridSpans.transformAbstractCoordinates(fixedTracksCount: tracks.count, flow: flow)
    var previousGrowingIndex: Int = 0
    var maxMainSizeInGrowing: CGFloat = 0

    // Update specific coordinates
    for data in coordinates.enumerated() {
      var item = data.element

      if previousGrowingIndex != item.startIndex[keyPath: flow.index(.main)] {
        let previousGroingItems = coordinates.enumerated().filter { $0.element.startIndex[keyPath: flow.index(.main)] == previousGrowingIndex }
        // 记录主轴位置
        var rowItemsMainGrowingMaxSize = previousGroingItems
          .filter { $0.element.child[keyPath: flow.spanIndex(.main)] <= 1 }
          .map { main($0.element.bounds.origin) + main($0.element.bounds.size) }
          .reduce(0) { max($0, $1) }
        if rowItemsMainGrowingMaxSize == 0 {
          rowItemsMainGrowingMaxSize = previousGroingItems
            .map { main($0.element.bounds.origin) + main($0.element.bounds.size) }
            .reduce(.infinity) { min($0, $1) }
        }
        syncMainAxisSize(previousGrowingIndex, coordinates: &coordinates)
        previousGrowingIndex = item.startIndex[keyPath: flow.index(.main)]
        maxMainSizeInGrowing = rowItemsMainGrowingMaxSize + mainSpacing
      }

      let crossSize = calculateTrackCrossWithCrossSize(trackOffset: item.startIndex[keyPath: flow.index(.cross)],
                                                       crossOffset: item.child[keyPath: flow.spanIndex(.cross)],
                                                       trackSizes: trackSizes)
      let render = item.child.layout(Constraint(minSize: size(main: 0, cross: crossSize), maxSize: size(main: .infinity, cross: crossSize)))
      let mainSize = main(render.size).meaningless(replace: crossSize)
      let crossPosition: CGFloat
      let crossOffset = item.startIndex[keyPath: flow.index(.cross)]
      if crossOffset == 0 {
        crossPosition = 0
      } else {
        crossPosition = calculateTrackCrossWithCrossSize(trackOffset: 0,
                                                         crossOffset: item.startIndex[keyPath: flow.index(.cross)],
                                                         trackSizes: trackSizes) + crossSpacing
      }
      item.bounds = CGRect(origin: point(main: maxMainSizeInGrowing, cross: crossPosition),
                           size: size(main: mainSize, cross: crossSize))
      coordinates[data.offset] = item
    }
    
    // 同步主轴大小
    let lastGroingIndex = coordinates.reduce(0) { max($0, $1.startIndex[keyPath: flow.index(.main)]) }
    syncMainAxisSize(lastGroingIndex, coordinates: &coordinates)
    
    // 更新占用
    updateOccupyMainAxis(coordinates: &coordinates)

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
}
