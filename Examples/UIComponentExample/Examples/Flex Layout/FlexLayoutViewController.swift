//
//  FlexLayoutViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/18.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

class Box: ComponentBuilder {
  let width: CGFloat
  let height: CGFloat
  let text: String
  init(_ text: String, width: CGFloat = 50, height: CGFloat = 50) {
    self.width = width
    self.height = height
    self.text = text
  }
  convenience init(_ index: Int, width: CGFloat = 50, height: CGFloat = 50) {
    self.init("\(index)", width: width, height: height)
  }
  func build() -> Component {
    Space(width: width, height: height).styleColor(.systemBlue).overlay(Text(text).textColor(.white).textAlignment(.center).size(width: .fill, height: .fill))
  }
}

extension Component {
  func styleColor(_ tintColor: UIColor) -> ViewUpdateComponent<ComponentDisplayableViewComponent<ComponentView>> {
    view().update {
      $0.backgroundColor = tintColor.withAlphaComponent(0.5)
      $0.layer.cornerRadius = 10
      $0.layer.cornerCurve = .continuous
      $0.layer.borderWidth = 2
      $0.layer.borderColor = tintColor.cgColor
    }
  }
}

class FlexLayoutViewController: ComponentViewController {
  
  override var component: Component {
    
    VStack(spacing: 20, bound: false) {
      Text("Flex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
      VStack(spacing: 10) {
        Text("H/VStack适用于更加复杂subviews布局")
        VStack(spacing: 10) {
          HStack(spacing: 10, alignItems: .center) {
            Image(systemName: "person.circle.fill").size(width: 100, height: .aspectPercentage(1))
            HStack(spacing: 5, justifyContent: .spaceBetween, alignItems: .center) {
              VStack(spacing: 5) {
                Text("nickname")
                HStack(justifyContent: .spaceBetween, alignItems: .center) {
                  Text("introduce myself...", font: .systemFont(ofSize: 13, weight: .light)).textColor(.secondaryLabel)
                  Text("gender: 👨").font(.systemFont(ofSize: 13, weight: .thin))
                }
              }.flex()
              VStack(justifyContent: .spaceEvenly) {
                Join {
                  Image(systemName: "sun.dust")
                  Image(systemName: "sun.haze")
                  Image(systemName: "cloud.bolt.rain.fill")
                } separator: {
                  Space(height: 5)
                }
              }
            }
          }
          HStack(spacing: 10, alignItems: .center) {
            Image(systemName: "display.2")
            Space().size(width: .aspectPercentage(1), height: .fill).inset(10).styleColor(.systemBlue)
            VStack(justifyContent: .spaceAround) {
              Text("Very powerful layout system...")
              HStack(spacing: 5, alignItems: .center) {
                Text("long long long long long Text").numberOfLines(1).flex()
                Image(systemName: "checkmark.shield.fill")
              }
            }.flex()
          }.size(height: 100).inset(10).styleColor(.systemGroupedBackground)
        }.view()
      }
      
      VStack(spacing: 10) {
        Text("Horizontal layouts")
        VStack(spacing: 10) {
          Text("FlexRow justify=spaceBetween")
          FlexRow(spacing: 10, justifyContent: .spaceBetween) {
            for index in 0...10 {
              Box(index)
            }
          }
        }.inset(10).styleColor(.systemGray4).size(width: .fill)
        
        VStack {
          Text("HStack (can scroll horizontally)").inset(top: 10, left: 10, bottom: 0, right: 10)
          HStack(spacing: 10, bound: false) {
            for index in 0...10 {
              Box(index)
            }
          }.inset(10).scrollView().showsHorizontalScrollIndicator(false)
        }.styleColor(.systemGray4)
      }.inset(10).styleColor(.systemGroupedBackground)
      
      VStack(spacing: 10) {
        Text("Vertical layouts")
        HStack(justifyContent: .spaceBetween) {
          VStack {
            Text("FlexColumn")
            Space(height: 10)
            FlexColumn(spacing: 10) {
              for index in 0...10 {
                Box(index)
              }
            }.size(height: 290)
          }.inset(10).styleColor(.systemGray4)
          Spacer()
          VStack {
            Space(height: 10)
            Text("VStack")
            VStack(spacing: 10, bound: false) {
              for index in 0...10 {
                Box(index)
              }
            }.inset(10).scrollView().showsVerticalScrollIndicator(false).size(height: 310)
          }.inset(h: 10).styleColor(.systemGray4)
        }
      }.inset(10).styleColor(.systemGroupedBackground)
      
      VStack(spacing: 10) {
        Text("Justify Content", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
        for justifyContent in MainAxisAlignment.allCases {
          Text("\(justifyContent)").size(width: .fill)
          Flow(justifyContent: justifyContent) {
            for index in 0..<10 {
              Box(index)
            }
          }.inset(10).styleColor(.systemGroupedBackground)
        }
      }
      
      VStack(spacing: 10) {
        Text("Align Items", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
        for alignItems in CrossAxisAlignment.allCases {
          Text("\(alignItems)").size(width: .fill)
          Flow(alignItems: alignItems) {
            for index in 0..<10 {
              Box(index, height: 50 + CGFloat(index % 4) * 10)
            }
          }.inset(10).styleColor(.systemGroupedBackground)
        }
      }
      
      VStack(spacing: 10) {
        Text("Align Content", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
        for alignContent in MainAxisAlignment.allCases {
          Text("\(alignContent)").size(width: .fill)
          Flow(alignContent: alignContent) {
            for index in 0..<10 {
              Box(index, height: 50)
            }
          }.size(height: 150).inset(10).styleColor(.systemGroupedBackground)
        }
      }
      
      
      VStack(spacing: 10) {
        Text("Flex", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
        Text("single flex").size(width: .fill)
        Flow() {
          Box(1)
          Box(2).flex()
          Box(3)
        }.inset(10).styleColor(.systemGroupedBackground)
        Text("2 flex").size(width: .fill)
        Flow() {
          Box(1)
          Box(2).flex()
          Box(3).flex()
          Box(4)
        }.inset(10).styleColor(.systemGroupedBackground)
        Text("2 flex on 1st line").size(width: .fill)
        Flow {
          Box(1)
          Box(2).flex()
          Box(3).flex()
          Box(4)
        }.size(width: 190).inset(10).styleColor(.systemGroupedBackground)
        Text("2 flex on 2nd line").size(width: .fill)
        Flow {
          Box(1)
          Box(2)
          Box(3)
          Box(4).flex()
          Box(5).flex()
        }.size(width: 190).inset(10).styleColor(.systemGroupedBackground)
      }
      
    }.inset(20)
  }
}
