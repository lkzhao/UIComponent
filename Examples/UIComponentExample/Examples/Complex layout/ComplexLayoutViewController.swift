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
  
  static let originalIds = [Cell.Context(fillColor: colors.randomElement()!, id: "1"),
                            Cell.Context(fillColor: colors.randomElement()!, id: "2"),
                            Cell.Context(fillColor: colors.randomElement()!, id: "3"),
                            Cell.Context(fillColor: colors.randomElement()!, id: "4"),
                            Cell.Context(fillColor: colors.randomElement()!, id: "5")]
  static let colors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemTeal, .systemGray, .systemFill, .systemGreen, .systemGreen, .systemYellow, .systemPurple, .systemOrange]
  
  var ids = originalIds {
    didSet {
      reloadComponent()
    }
  }
  
  lazy var waterfallData: [(CGSize, UIColor)] = {
    var sizes = [(CGSize, UIColor)]()
    for _ in 1 ... 30 {
      sizes.append((CGSize(width: Int(arc4random_uniform(300 - 100)) + 100, height: Int(arc4random_uniform(300 - 100)) + 100), ComplexLayoutViewController.colors.randomElement()!))
    }
    return sizes
  }()
  
  lazy var resetButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Reset", for: .normal)
    button.addTarget(self, action: #selector(self.resetIds), for: .touchUpInside)
    return button
  }()
  
  lazy var shuffledBuuton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Shuffled", for: .normal)
    button.addTarget(self, action: #selector(self.resetIds), for: .touchUpInside)
    return button
  }()
  
  
  override var component: Component {
    VStack(spacing: 20) {
      Text("Complex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill)
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
      }
      
      VStack(spacing: 10) {
        Text("Horizontal list").inset(left: 10)
        HStack(spacing: 10, alignItems: .center) {
          if ids.isEmpty {
            Text("No data here", font: .systemFont(ofSize: 17, weight: .medium)).flex()
          } else {
            for (offset, element) in ids.enumerated() {
              Cell(data: element).tappableView { [weak self] in
                guard let self = self else { return }
                self.ids.remove(at: offset)
              }
            }
          }
        }.inset(h: 10).inset(top: 5).scrollView().showsHorizontalScrollIndicator(false).animator(AnimatedReloadAnimator())
        HStack(spacing: 10) {
          SimpleViewComponent<UIButton>(view: resetButton).isEnabled(self.ids.count != 5)
          SimpleViewComponent<UIButton>(view: shuffledBuuton).isEnabled(self.ids.count != 0)
        }.inset(left: 10)
      }.inset(v: 10).styleColor(.systemGroupedBackground)
      
      Text("Waterfall", font: .boldSystemFont(ofSize: 20))
      VStack(spacing: 10) {
        Text("Horizontal waterfall").inset(left: 10)
        HorizontalWaterfall(columns: 3, spacing: 5) {
          for (index, data) in self.waterfallData.enumerated() {
            let size = data.0
            Space().size(width: .aspectPercentage(size.width/size.height), height: .fill).styleColor(data.1).overlay(Text("\(index)").textAlignment(.center))
          }
        }.inset(h: 10).size(height: .absolute(300)).scrollView().showsHorizontalScrollIndicator(false)
      }.inset(v: 10).styleColor(.systemGroupedBackground)
      
      VStack(spacing: 10) {
        Text("Vertical waterfall").inset(left: 10)
        Waterfall(columns: 3, spacing: 5) {
          for (index, data) in self.waterfallData.enumerated() {
            let size = data.0
            Space().size(width: .fill, height: .aspectPercentage(size.height/size.width)).styleColor(data.1).overlay(Text("\(index)").textAlignment(.center))
          }
        }.inset(h: 10).size(width: .fill)
      }.inset(v: 10).styleColor(.systemGroupedBackground)
      
    }.inset(20)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
  @objc func resetIds() {
    ids = ComplexLayoutViewController.originalIds.shuffled()
  }
  
  @objc func shuffled() {
    ids = ids.shuffled()
  }
  
}
