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
  init(height: CGFloat = 50) {
    self.height = height
  }
  func build() -> Component {
    SimpleViewComponent<UIView>()
      .size(width: 50, height: height)
      .styleColor(.systemBlue)
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
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
        }
      }.inset(10).view().styleColor(.systemGray)
      
      VStack {
        Text("HStack noWrap(can scroll horizontally)").inset(10)
        HStack(spacing: 10, wrapper: .noWrap) {
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
        }.scrollView().showsHorizontalScrollIndicator(false).contentInset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        Space(height: 10)
      }.view().styleColor(.systemGray)
      
      HStack (spacing: 10) {
        VStack {
          Text("VStack wrap")
          Space(height: 10)
          VStack(spacing: 10, wrapper: .wrap) {
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
          }.size(height: 300)
        }.inset(10).view().styleColor(.systemOrange)
        
        VStack {
          Text("VStack noWrap")
          Space(height: 10)
          VStack(spacing: 20, wrapper: .noWrap) {
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
            Box()
          }.size(height: 300)
        }.inset(10).view().styleColor(.systemOrange)
      }
      
      VStack {
        Text("HStack alignItems end")
        Space(height: 10)
        HStack(spacing: 10, alignItems: .end, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack alignItems center")
        Space(height: 10)
        HStack(spacing: 10, alignItems: .center, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
    
      VStack {
        Text("HStack justifyContent end")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .end, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack justifyContent center")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .center, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack justifyContent spaceBetween")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .spaceBetween, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack justifyContent spaceAround")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .spaceAround, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack justifyContent spaceEvenly")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .spaceEvenly, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemTeal)
      
      VStack {
        Text("HStack justifyContent start")
        Space(height: 10)
        HStack(spacing: 10, justifyContent: .start, wrapper: .wrap) {
          Box(height: 100)
          Box()
          Box()
          Box()
          Box()
          Box()
          Box()
          Box(height: 100)
        }
      }.inset(10).view().styleColor(.systemRed)
      
    }.inset(10)
    
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
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
