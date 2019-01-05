//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol Provider {
  func layout(size: CGSize) -> CGSize
  func views(in frame: CGRect) -> [(ViewProvider, CGRect)]

  func getIntrinsicWidth(height: CGFloat) -> CGFloat
  func getIntrinsicHeight(width: CGFloat) -> CGFloat
}

public protocol ViewProvider: Provider {
  var key: String { get }
  var animator: Animator? { get }
  func construct() -> UIView
  func update(view: UIView)
}

open class MultiChildProvider: Provider {
  open var children: [Provider] = []
  init(children: [Provider]) {
    self.children = children
  }
  open func layout(size: CGSize) -> CGSize {
    fatalError()
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    fatalError()
  }
  open func getIntrinsicHeight(width: CGFloat) -> CGFloat {
    return 0
  }
  open func getIntrinsicWidth(height: CGFloat) -> CGFloat {
    return 0
  }
}

open class SingleChildProvider: Provider {
  open var child: Provider
  init(child: Provider) {
    self.child = child
  }
  open func layout(size: CGSize) -> CGSize {
    return child.layout(size: size)
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return child.views(in: frame)
  }
  open func getIntrinsicHeight(width: CGFloat) -> CGFloat {
    return child.getIntrinsicHeight(width: width)
  }
  open func getIntrinsicWidth(height: CGFloat) -> CGFloat {
    return child.getIntrinsicWidth(height: height)
  }
}

open class LayoutProvider: MultiChildProvider {
  public private(set) var frames: [CGRect] = []
  open var transposed = false

  open func simpleLayout(size: CGSize) -> [CGRect] {
    fatalError("Subclass should provide its own layout")
  }

  open func doneLayout() {

  }

  open func getSize(child: Provider, maxSize: CGSize) -> CGSize {
    if transposed {
      return child.layout(size: maxSize.transposed).transposed
    }
    return child.layout(size: maxSize)
  }

  open override func layout(size: CGSize) -> CGSize {
    if transposed {
      frames = simpleLayout(size: size.transposed).map { $0.transposed }
    } else {
      frames = simpleLayout(size: size)
    }
    let contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
      }.size
    doneLayout()
    return contentSize
  }

  open override func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    var result = [(ViewProvider, CGRect)]()
    for (i, childFrame) in frames.enumerated() where frame.intersects(childFrame) {
      let child = children[i]
      let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map { ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size)) }
      result.append(contentsOf: childResult)
    }
    return result
  }
}

open class SortedLayoutProvider: LayoutProvider {
  private var maxFrameLength: CGFloat = 0
  open var isImplementedInVertical: Bool { return true }

  open override func doneLayout() {
    if transposed == isImplementedInVertical {
      maxFrameLength = frames.max { $0.width < $1.width }?.width ?? 0
    } else {
      maxFrameLength = frames.max { $0.height < $1.height }?.height ?? 0
    }
  }
  
  open override func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    var result = [(ViewProvider, CGRect)]()
    if transposed == isImplementedInVertical {
      var index = frames.binarySearch { $0.minX < frame.minX - maxFrameLength }
      while index < frames.count {
        let childFrame = frames[index]
        if childFrame.minX >= frame.maxX {
          break
        }
        if childFrame.maxX > frame.minX {
          let child = children[index]
          let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
            ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
          }
          result.append(contentsOf: childResult)
        }
        index += 1
      }
    } else {
      var index = frames.binarySearch { $0.minY < frame.minY - maxFrameLength }
      while index < frames.count {
        let childFrame = frames[index]
        if childFrame.minY >= frame.maxY {
          break
        }
        if childFrame.maxY > frame.minY {
          let child = children[index]
          let childResult = child.views(in: frame.intersection(childFrame) - childFrame.origin).map {
            ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size))
          }
          result.append(contentsOf: childResult)
        }
        index += 1
      }
    }

    return result
  }
}

class WaterfallLayoutProvider: SortedLayoutProvider {
  public var columns: Int
  public var spacing: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 2, spacing: CGFloat = 0, children: [Provider]) {
    self.columns = columns
    self.spacing = spacing
    super.init(children: children)
  }

  override func simpleLayout(size: CGSize) -> [CGRect] {
    var frames: [CGRect] = []

    let columnWidth = (size.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for child in children {
      var cellSize = getSize(child: child, maxSize: CGSize(width: columnWidth, height: size.height))
      cellSize = CGSize(width: columnWidth, height: cellSize.height)
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += cellSize.height + spacing
      let frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                         y: offsetY),
                         size: cellSize)
      frames.append(frame)
    }

    return frames
  }
}

class HorizontalWaterfallLayoutProvider: WaterfallLayoutProvider {
  public override init(columns: Int = 2, spacing: CGFloat = 0, children: [Provider]) {
    super.init(columns: columns, spacing: spacing, children: children)
    self.transposed = true
  }
}

open class InsetLayoutProvider: Provider {
  var insets: UIEdgeInsets
  var child: Provider

  init(insets: UIEdgeInsets, child: Provider) {
    self.insets = insets
    self.child = child
  }

  open func layout(size: CGSize) -> CGSize {
    return child.layout(size: size.insets(by: insets)).insets(by: -insets)
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return child.views(in: frame.inset(by: -insets)).map {
      ($0.0, $0.1 + CGPoint(x: insets.left, y: insets.top))
    }
  }
  open func getIntrinsicWidth(height: CGFloat) -> CGFloat {
    let vInsets = insets.bottom + insets.top
    let hInsets = insets.left + insets.right
    return child.getIntrinsicWidth(height: height - vInsets) + hInsets
  }
  open func getIntrinsicHeight(width: CGFloat) -> CGFloat {
    let vInsets = insets.bottom + insets.top
    let hInsets = insets.left + insets.right
    return child.getIntrinsicHeight(width: width - hInsets) + vInsets
  }
}

open class BaseViewProvider<View: UIView>: ViewProvider {
  public var key: String

  public typealias ViewGenerator = () -> View
  public typealias ViewUpdater = (View) -> Void
  public typealias SizeGenerator = (CGSize) -> CGSize

  public var animator: Animator?
  public var viewGenerator: ViewGenerator?
  public var viewUpdater: ViewUpdater?
  public var sizeSource: SizeGenerator?

  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              update: ViewUpdater?,
              size: SizeGenerator?) {
    self.key = key
    self.animator = animator
    self.viewUpdater = update
    self.sizeSource = size
  }

  public func construct() -> UIView {
    if let viewGenerator = viewGenerator {
      return viewGenerator()
    } else {
      return View()
    }
  }

  public func update(view: UIView) {
    guard let view = view as? View else { return }
    viewUpdater?(view)
  }

  var _size: CGSize = .zero
  public func layout(size: CGSize) -> CGSize {
    if let sizeSource = sizeSource {
      _size = sizeSource(size)
      return _size
    } else {
      return .zero
    }
  }

  public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return [(self, CGRect(origin: .zero, size: _size))]
  }

  public func getIntrinsicWidth(height: CGFloat) -> CGFloat {
    return 0
  }

  public func getIntrinsicHeight(width: CGFloat) -> CGFloat {
    return 0
  }
}
