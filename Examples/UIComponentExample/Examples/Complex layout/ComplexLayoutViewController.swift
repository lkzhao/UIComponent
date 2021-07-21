//
//  ComplexLayoutViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent

class ComplexLayoutViewController: ComponentViewController {
  
  var showWeather: Bool = false
  
  var ids = ["1", "2", "3", "4", "5"]
  
  
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

      HStack(spacing: 10) {
        for (offset, element) in ids.enumerated() {
          Cell(id: element).tappableView { [weak self] in
            guard let self = self else { return }
            self.ids.remove(at: offset)
            self.reloadComponent()
          }
        }
      }.inset(20).scrollView().animator(AnimatedReloadAnimator())
      
    }
  }
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      componentView.animator = AnimatedReloadAnimator()
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
