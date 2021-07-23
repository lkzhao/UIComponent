//
//  IntroductionCard.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/22.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

struct IntroductionCard: ComponentBuilder {
  private let longText = """
    Write UI in crazy speed, with great perf & no limitations.
    SwiftUI still haven't satisfied my requirements. So I build this.
    
    This framework allows you to build UI using UIKit with syntax similar to SwiftUI. You can think about this as an improved UICollectionView.
    
    Great performance through global cell reuse.
    Built in layouts including Stack, Flow, & Waterfall.
    Declaritive API based on resultBuilder and modifier syntax.
    Work seemless with existing UIKit views, viewControllers, and transitions.
    dynamicMemberLookup support for all ViewComponents which can help you easily update your UIKit views.
    Animator API to apply animations when cells are being moved, updated, inserted, or deleted.
    Simple architecture for anyone to be able to understand.
    Easy to create your own Components.
    No state management or two-way binding.
    """
  
  
  let isExpand: Bool
  let tapHandler: () -> Void
  
  func build() -> Component {
    HStack(spacing: 15, alignItems: .stretch) {
      VStack(spacing: 5, alignItems: .center) {
        AsyncImage(URL(string: "https://unsplash.com/photos/MR2A97jFDAs/download?force=true&w=640")!).size(width: 50, height: 50).update{$0.layer.cornerRadius = 50/2}.clipsToBounds(true)
        Text("isExpand: \(isExpand)", font: .systemFont(ofSize: 10, weight: .light)).id("label.state.\(isExpand)")
        Spacer()
        Image(systemName: isExpand ? "rectangle.compress.vertical" : "rectangle.expand.vertical").tappableView {
          tapHandler()
        }
      }
      VStack(spacing: 5) {
        Text("UIComponent", font: .boldSystemFont(ofSize: 17))
        Text("Powerful layout", font: .systemFont(ofSize: 14)).textColor(.link)
        if isExpand {
          Text(longText, font: .systemFont(ofSize: 13)).textColor(.secondaryLabel)
        } else {
          Text(longText, font: .systemFont(ofSize: 13)).textColor(.secondaryLabel).numberOfLines(2).size(height: 35)
        }
      }.flex()
    }.inset(10).defaultShadow().with(\.animator, AnimatedReloadAnimator()).id("introduction")
  }
}

extension IntroductionCard {
  init(_ isExpand: Bool, tapHandler: @escaping () -> Void) {
    self.isExpand = isExpand
    self.tapHandler = tapHandler
  }
}
