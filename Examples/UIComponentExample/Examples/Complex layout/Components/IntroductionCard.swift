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
  
  
  let expand: Bool
  let tapHandler: (Bool) -> Void
  
  func build() -> Component {
    HStack(spacing: 15) {
      VStack(spacing: 10, justifyContent: .spaceBetween, alignItems: .center) {
        AsyncImage(URL(string: "https://unsplash.com/photos/MR2A97jFDAs/download?force=true&w=640")!).size(width: 50, height: 50).update{$0.layer.cornerRadius = 50/2}.clipsToBounds(true)
        Image(systemName: expand ? "rectangle.compress.vertical" : "rectangle.expand.vertical").tappableView {
          tapHandler(expand)
        }
      }
      VStack(spacing: 5) {
        Text("UIComponent", font: .boldSystemFont(ofSize: 17))
        Text("Powerful layout", font: .systemFont(ofSize: 14)).textColor(.link)
        if expand {
          Text(longText, font: .systemFont(ofSize: 13)).textColor(.secondaryLabel)
        } else {
          Text(longText, font: .systemFont(ofSize: 13)).textColor(.secondaryLabel).numberOfLines(2).size(height: 40)
        }
      }.flex()
    }.inset(10).shadow().with(\.animator, AnimatedReloadAnimator()).flex()
  }
}
