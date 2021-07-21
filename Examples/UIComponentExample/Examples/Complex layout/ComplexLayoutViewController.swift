//
//  ComplexLayoutViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit.UIButton

class ComplexLayoutViewController: ComponentViewController {
  
  var showWeather: Bool = false
  
  static let originalIds = [Cell.Context(fillColor: .systemRed, id: "1"),
                     Cell.Context(fillColor: .systemBlue, id: "2"),
                     Cell.Context(fillColor: .systemPink, id: "3"),
                     Cell.Context(fillColor: .systemTeal, id: "4"),
                     Cell.Context(fillColor: .systemGreen, id: "5")]
  
  var ids = originalIds
  
  lazy var resetButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("reset", for: .normal)
    button.addTarget(self, action: #selector(self.resetIds), for: .touchUpInside)
    return button
  }()
  
  lazy var shuffledBuuton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("shuffled", for: .normal)
    button.addTarget(self, action: #selector(self.resetIds), for: .touchUpInside)
    return button
  }()
  
  
  override var component: Component {
    VStack(spacing: 20) {
      Text("Complex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill).inset(top:20, left: 20)
      VStack(spacing: 10) {
        UserProfile(avatar: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640",
                    userName: "Jack",
                    introduce: "This is simply amazing",
                    gender: "🦄",
                    showWeather: showWeather)
        Text(showWeather ? "Hide weather" : "Show weather").textColor(.systemBlue).tappableView { [weak self] in
          guard let self = self else { return }
          self.showWeather = !self.showWeather
          self.reloadComponent()
        }
      }.inset(20)
      
      VStack(spacing: 10) {
        HStack(spacing: 10, alignItems: .center) {
          if ids.isEmpty {
            Text("No data", font: .systemFont(ofSize: 17, weight: .medium))
          } else {
            for (offset, element) in ids.enumerated() {
              Cell(data: element).tappableView { [weak self] in
                guard let self = self else { return }
                self.ids.remove(at: offset)
                self.reloadComponent()
              }
            }
          }
        }.inset(h: 20).scrollView().animator(AnimatedReloadAnimator())
        HStack(spacing: 10) {
          SimpleViewComponent<UIButton>(view: resetButton).isEnabled(self.ids.count != 5).inset(left: 20)
          SimpleViewComponent<UIButton>(view: shuffledBuuton).isEnabled(self.ids.count != 0)
        }
      }
    }
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
  
  @objc func resetIds() {
    ids = ComplexLayoutViewController.originalIds.shuffled()
    self.reloadComponent()
  }
  
  @objc func shuffled() {
    ids = ids.shuffled()
    self.reloadComponent()
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
