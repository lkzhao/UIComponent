//
//  FlexLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-02.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public struct Flex: Provider {
	public let flex: CGFloat
  public let child: Provider

	public init(weight: CGFloat = 1, child: Provider = SpaceProvider()) {
		self.flex = weight
    self.child = child
	}
  
  public func layout(size: CGSize) -> LayoutNode {
    child.layout(size: size)
  }
}

public struct StackConfig {
  var spacing: CGFloat
  var alignItems: AlignItem
  var justifyContent: JustifyContent

  var fitCrossAxis: Bool = false
  var alwaysFillEmptySpaces: Bool = true
  var passThroughParentSize: Bool = false
}

public protocol StackLayout: LayoutProvider {
  var children: [Provider] { get }
  var config: StackConfig { get set }
}

extension StackLayout {
  public var spacing: CGFloat {
    get { config.spacing }
    set { config.spacing = newValue }
  }
  public var alignItems: AlignItem {
    get { config.alignItems }
    set { config.alignItems = newValue }
  }
  public var justifyContent: JustifyContent {
    get { config.justifyContent }
    set { config.justifyContent = newValue }
  }
  public var fitCrossAxis: Bool {
    get { config.fitCrossAxis }
    set { config.fitCrossAxis = newValue }
  }
  public var alwaysFillEmptySpaces: Bool {
    get { config.alwaysFillEmptySpaces }
    set { config.alwaysFillEmptySpaces = newValue }
  }
  public var passThroughParentSize: Bool {
    get { config.passThroughParentSize }
    set { config.passThroughParentSize = newValue }
  }

  public func simpleLayoutWithCustomSize(size: CGSize) -> (([LayoutNode], [CGRect]), CGSize) {
    let (nodes, totalWidth) = getLayoutNodes(size: size)

    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: size.width,
                                                               totalPrimary: totalWidth,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: children.count)

    var upperBound = size.height
    if fitCrossAxis || upperBound == .infinity {
      upperBound = nodes.max(by: { a, b in
        a.size.height < b.size.height
      })?.size.height ?? 0
    }

    let (frames, contentSize) = LayoutHelper.alignItem(alignItems: alignItems,
                                                       startingPrimaryOffset: offset, spacing: distributedSpacing,
                                                       sizes: nodes.lazy.map({ $0.size }), secondaryRange: 0 ... max(0, upperBound))
    return ((nodes, frames), contentSize)
  }

  public func getLayoutNodes(size: CGSize) -> (nodes: [LayoutNode], totalWidth: CGFloat) {
    var nodes: [LayoutNode] = []
    let spacings = spacing * CGFloat(children.count - 1)
    var freezedWidth = spacings
    var fillIndexes: [Int] = []
    var totalFlex: CGFloat = 0

    for (i, child) in children.enumerated() {
      if let child = child as? Flex {
        totalFlex += child.flex
        fillIndexes.append(i)
        nodes.append(SpaceLayoutNode(size: .zero))
      } else {
        let node = getLayoutNode(child: child, maxSize: CGSize(width: passThroughParentSize ? size.width : .infinity,
                                                               height: size.height))
        nodes.append(node)
        freezedWidth += node.size.width
      }
    }

    let widthPerFlex: CGFloat = max(0, size.width - freezedWidth) / max(totalFlex, 1)
    for i in fillIndexes {
      let child = children[i] as! Flex
      let size = getLayoutNode(child: child, maxSize: CGSize(width: widthPerFlex * child.flex,
                                                       height: size.height))
      let width = alwaysFillEmptySpaces ? max(widthPerFlex, size.size.width) : size.size.width
      nodes[i] = SizeOverrideLayoutNode(child: size, size: CGSize(width: width, height: size.size.height))
      freezedWidth += nodes[i].size.width
    }

    return (nodes, freezedWidth - spacings)
  }
}


public struct HStack: StackLayout {
  public var config: StackConfig
  public var children: [Provider]

  public init(spacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              children: [Provider]) {
    self.children = children
    self.config = StackConfig(spacing: spacing, alignItems: alignItems, justifyContent: justifyContent)
  }

  public var isVerticalLayout: Bool {
    return false
  }
}

public struct VStack: StackLayout {
  public var config: StackConfig
  public var children: [Provider]

  public init(spacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              children: [Provider]) {
    self.children = children
    self.config = StackConfig(spacing: spacing, alignItems: alignItems, justifyContent: justifyContent)
  }

  public var isVerticalLayout: Bool {
    return false
  }
  
  public var isTransposed: Bool {
    return true
  }
}

struct SizeOverrideLayoutNode: LayoutNode {
  let child: LayoutNode
  let size: CGSize
  func views(in frame: CGRect) -> [(AnyViewProvider, CGRect)] {
    child.views(in: frame)
  }
}

public extension VStack {
  init(spacing: CGFloat = 0, justifyContent: JustifyContent = .start, alignItems: AlignItem = .start, @ProviderBuilder _ content: () -> ProviderBuilderComponent) {
    self.init(spacing: spacing, justifyContent: justifyContent, alignItems: alignItems, children: content().providers)
  }
}

public extension HStack {
  init(spacing: CGFloat = 0, justifyContent: JustifyContent = .start, alignItems: AlignItem = .start, @ProviderBuilder _ content: () -> ProviderBuilderComponent) {
    self.init(spacing: spacing, justifyContent: justifyContent, alignItems: alignItems, children: content().providers)
  }
}

public typealias RowLayout = HStack
public typealias ColumnLayout = VStack
