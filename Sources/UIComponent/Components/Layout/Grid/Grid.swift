//  Created by y H on 2022/4/5.

import CoreGraphics

public enum GridFlow {
  case rows
  case columns
}

public struct Grid: GridLayout {
  public var mainSpacing: CGFloat

  public var crossSpacing: CGFloat

  public var tracks: [GridTrack]

  public var children: [Component]

  public var flow: GridFlow

  public init(tracks: [GridTrack], flow: GridFlow, mainSpacing: CGFloat, crossSpacing: CGFloat, children: [Component]) {
    self.tracks = tracks
    self.flow = flow
    self.mainSpacing = mainSpacing
    self.crossSpacing = crossSpacing
    self.children = children
  }

  public func main(_ size: CGPoint) -> CGFloat {
    flow == .columns ? size.x : size.y
  }

  public func cross(_ size: CGPoint) -> CGFloat {
    flow == .columns ? size.y : size.x
  }

  public func main(_ size: CGSize) -> CGFloat {
    flow == .columns ? size.width : size.height
  }

  public func cross(_ size: CGSize) -> CGFloat {
    flow == .columns ? size.height : size.width
  }

  public func size(main: CGFloat, cross: CGFloat) -> CGSize {
    CGSize(width: flow == .columns ? main : cross,
           height: flow == .columns ? cross : main)
  }

  public func point(main: CGFloat, cross: CGFloat) -> CGPoint {
    CGPoint(
      x: flow == .columns ? main : cross,
      y: flow == .columns ? cross : main
    )
  }

  public func renderNode(size: CGSize, children: [RenderNode], positions: [CGPoint]) -> RenderNode {
    SlowRenderNode(size: size, children: children, positions: positions)
  }
}
