//
//  FlowViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 7/18/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

private struct FlowItem: ComponentBuilder {
  let size: CGSize
  func build() -> Component {
    Space(size: size).view().backgroundColor(.systemBlue.withAlphaComponent(0.2)).with(\.layer.cornerRadius, 8).with(\.layer.borderColor, UIColor.systemBlue.cgColor).with(\.layer.borderWidth, 2)
  }
}

class FlowViewController: ComponentViewController {
  override var component: Component {
    VStack(spacing: 50) {
      VStack(spacing: 10) {
        Text("Justify Content", font: UIFont.boldSystemFont(ofSize: 20)).size(width: .fill)
        for justifyContent in MainAxisAlignment.allCases {
          Text("\(justifyContent)").size(width: .fill)
          Flow(justifyContent: justifyContent) {
            for _ in 0..<10 {
              FlowItem(size: CGSize(width: 50, height: 50))
            }
          }
        }
      }
      
      VStack(spacing: 10) {
        Text("Align Items", font: UIFont.boldSystemFont(ofSize: 20)).size(width: .fill)
        for alignItems in CrossAxisAlignment.allCases {
          Text("\(alignItems)").size(width: .fill)
          Flow(alignItems: alignItems) {
            for i in 0..<10 {
              FlowItem(size: CGSize(width: 50, height: 50 + (i % 4) * 10))
            }
          }
        }
      }
      
      VStack(spacing: 10) {
        Text("Align Content", font: UIFont.boldSystemFont(ofSize: 20)).size(width: .fill)
        for alignContent in MainAxisAlignment.allCases {
          Text("\(alignContent)").size(width: .fill)
          Flow(alignContent: alignContent) {
            for _ in 0..<10 {
              FlowItem(size: CGSize(width: 50, height: 50))
            }
          }.size(height: 150).view().backgroundColor(.systemBlue.withAlphaComponent(0.2))
        }
      }
      
      
      VStack(spacing: 10) {
        Text("Flex", font: UIFont.boldSystemFont(ofSize: 20)).size(width: .fill)
        Text("single flex").size(width: .fill)
        Flow() {
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50))
        }
        Text("2 flex").size(width: .fill)
        Flow() {
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50))
        }
        Text("2 flex on 1st line").size(width: .fill)
        Flow {
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50))
        }.size(width: 190).view().backgroundColor(.systemBlue.withAlphaComponent(0.2))
        Text("2 flex on 2nd line").size(width: .fill)
        Flow {
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50))
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
          FlowItem(size: CGSize(width: 50, height: 50)).flex()
        }.size(width: 190).view().backgroundColor(.systemBlue.withAlphaComponent(0.2))
      }
    }.inset(20)
  }
}


