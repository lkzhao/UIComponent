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
  let height: CGFloat
  let text: String
  init(_ text: String, height: CGFloat = 50) {
    self.height = height
    self.text = text
  }
  func build() -> Component {
    SimpleViewComponent<UIView>()
      .size(width: 50, height: height)
      .styleColor(.systemBlue).overlay(Text(text).textColor(.white).textAlignment(.center).size(width: .fill, height: .fill))
  }
  
  
}

extension ViewComponent {
  func styleColor(_ tintColor: UIColor) -> ViewUpdateComponent<Self> {
     update {
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
    return VStack(spacing: 20) {
      Text("Flex layouts", font: .systemFont(ofSize: 20, weight: .bold)).textColor(.label).textAlignment(.center).size(width: .fill)
      VStack {
        Text("HStack wrap")
        Space(height: 10)
        HStack(spacing: 10, wrapper: .wrap) {
          for index in 0...10 {
            Box("\(index)")
          }
        }
      }.inset(10).view().styleColor(.systemGray)
      
      VStack {
        Text("HStack noWrap(can scroll horizontally)").inset(10)
        HStack(spacing: 10, wrapper: .noWrap) {
          for index in 0...10 {
            Box("\(index)")
          }
        }.scrollView().showsHorizontalScrollIndicator(false).contentInset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        Space(height: 10)
      }.view().styleColor(.systemGray)
      
      HStack (spacing: 10) {
        VStack {
          Text("VStack wrap")
          Space(height: 10)
          VStack(spacing: 10, wrapper: .wrap) {
            for index in 0...10 {
              Box("\(index)")
            }
          }.size(height: 300)
        }.inset(10).view().styleColor(.systemOrange)
        
        VStack {
          Text("VStack noWrap")
          Space(height: 10)
          VStack(spacing: 20, wrapper: .noWrap) {
            for index in 0...10 {
              Box("\(index)")
            }
          }.size(height: 300)
        }.inset(10).view().styleColor(.systemOrange)
      }
      
      genHStack(wrapper: .wrap, justifyContent: .start, alignItems: .end)
      genHStack(wrapper: .wrap, justifyContent: .start, alignItems: .start)
      genHStack(wrapper: .wrap, justifyContent: .end, alignItems: .start)
      genHStack(wrapper: .wrap, justifyContent: .center, alignItems: .start)
      genHStack(wrapper: .wrap, justifyContent: .spaceBetween, alignItems: .start)
      genHStack(wrapper: .wrap, justifyContent: .spaceAround, alignItems: .start)
      genHStack(wrapper: .wrap, justifyContent: .spaceEvenly, alignItems: .start)
      
    }.inset(10)
    
    
  }
  
  func genHStack(wrapper: Wrapper, justifyContent: MainAxisAlignment, alignItems: CrossAxisAlignment) -> Component {
    VStack(spacing: 10) {
      Text("HStack\njustifyContent: .\(justifyContent)\nalignItems: .\(alignItems)\nwrapper: .\(wrapper)")
      HStack(spacing: 10, justifyContent: justifyContent, alignItems: alignItems, wrapper: wrapper) {
        for index in 0...10 {
          if index == 0 {
            Box("\(index)", height: 100)
          } else if index == 9 {
            Box("\(index)", height: 100)
          } else {
            Box("\(index)")
          }
        }
      }.inset(10).view().styleColor(.systemTeal)
    }.inset(10)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    /*
     
     
     */
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
