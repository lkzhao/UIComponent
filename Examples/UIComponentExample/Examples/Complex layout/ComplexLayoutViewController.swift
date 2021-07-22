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
  
  typealias Tag = (name: String, color: UIColor)
  typealias WaterfallItem = (size: CGSize, color: UIColor)
  
  static let defaultHorizontalData = [HorizontalCartItem.Context(fillColor: colors.randomElement()!),
                                      HorizontalCartItem.Context(fillColor: colors.randomElement()!),
                                      HorizontalCartItem.Context(fillColor: colors.randomElement()!),
                                      HorizontalCartItem.Context(fillColor: colors.randomElement()!),
                                      HorizontalCartItem.Context(fillColor: colors.randomElement()!)]
  static let colors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemTeal, .systemGray, .systemFill, .systemGreen, .systemGreen, .systemYellow, .systemPurple, .systemOrange]
  
  var horizontalData = defaultHorizontalData {
    didSet {
      reloadComponent()
    }
  }
  
  var tags: [Tag] = [("Hello", .systemOrange),
                     ("UIComponent", .systemPink),
                     ("SwiftUI", .systemRed),
                     ("Vue", .systemGreen),
                     ("Flex Layout", .systemTeal)] {
    didSet {
      reloadComponent()
    }
  }
  
  var showWeather: Bool = false {
    didSet {
      reloadComponent()
    }
  }
  
  var isExpanded = false {
    didSet {
      reloadComponent()
    }
  }
  
  lazy var waterfallData: [WaterfallItem] = {
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
  
  lazy var shuffleButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Shuffle", for: .normal)
    button.addTarget(self, action: #selector(self.resetIds), for: .touchUpInside)
    return button
  }()
  
  
  override var component: Component {
    VStack(spacing: 20) {
      Text("Complex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill).id("label")
      VStack(spacing: 10) {
        UserProfile(avatar: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640",
                    userName: "Jack",
                    introduce: "This is simply amazing",
                    showWeather: showWeather)
        Text(showWeather ? "Hide weather" : "Show weather").textColor(.systemBlue).tappableView { [unowned self] in
          self.showWeather.toggle()
        }.id("2")
      }
      
      IntroductionCard(isExpanded) { [unowned self] in
        self.isExpanded.toggle()
      }
      
      Text("Tag view", font: .boldSystemFont(ofSize: 20)).id("label2")
      VStack(spacing: 10) {
        Text("Tags row")
        Flow(spacing: 5, alignItems: .center) {
          if tags.isEmpty {
            Text("Empty Tag")
          } else {
            for (index, tag) in tags.enumerated() {
              Text(tag.name, font: .systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.color).tappableView { [unowned self] in
                self.tags.remove(at: index)
              }.id(tag.name)
            }
          }
          HStack(alignItems: .center) {
            Image(systemName: "plus")
            Text("Add new", font: .systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
          }.inset(h: 10, v: 5).styleColor(.systemGray5).tappableView { [unowned self] in
            self.showAlert()
          }
        }.view().with(\.animator, AnimatedReloadAnimator())
        Separator()
        Text("Tags column")
        FlexColumn(spacing: 5) {
          if tags.isEmpty {
            Text("Empty Tag")
          } else {
            for (index, tag) in tags.enumerated() {
              Text(tag.0, font: .systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.1).tappableView { [unowned self] in
                self.tags.remove(at: index)
              }.id(tag.0)
            }
          }
          HStack(alignItems: .center) {
            Image(systemName: "plus")
            Text("Add new", font: .systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
          }.inset(h: 10, v: 5).styleColor(.systemGray5).tappableView { [unowned self] in
            self.showAlert()
          }
        }.size(height: 150).view().with(\.animator, AnimatedReloadAnimator())
        
        Text("Shuffle tags").textColor(.systemBlue).tappableView { [unowned self] in
          self.tags = self.tags.shuffled()
        }
      }.inset(10).styleColor(.systemGroupedBackground).id("tag")
      
      VStack(spacing: 10) {
        Text("Horizontal list").inset(left: 10)
        HStack(spacing: 10, alignItems: .center) {
          if horizontalData.isEmpty {
            Text("No data here", font: .systemFont(ofSize: 17, weight: .medium)).flex()
          } else {
            for (offset, element) in horizontalData.enumerated() {
              HorizontalCartItem(data: element).tappableView { [unowned self] in
                self.horizontalData.remove(at: offset)
              }
            }
          }
        }.inset(h: 10).inset(top: 5).scrollView().showsHorizontalScrollIndicator(false).with(\.animator, AnimatedReloadAnimator())
        HStack(spacing: 10) {
          SimpleViewComponent<UIButton>(view: resetButton).isEnabled(self.horizontalData.count != 5).id("reset")
          SimpleViewComponent<UIButton>(view: shuffleButton).isEnabled(self.horizontalData.count != 0).id("shuffled")
        }.inset(left: 10)
      }.inset(v: 10).styleColor(.systemGroupedBackground).id("horizontal")
      
      Text("Waterfall", font: .boldSystemFont(ofSize: 20)).id("label3")
      VStack(spacing: 10) {
        Text("Horizontal waterfall").inset(left: 10)
        HorizontalWaterfall(columns: 3, spacing: 5) {
          for (index, data) in self.waterfallData.enumerated() {
            let size = data.0
            Space().size(width: .aspectPercentage(size.width/size.height), height: .fill).styleColor(data.1).overlay(Text("\(index)").textAlignment(.center))
          }
        }.inset(h: 10).size(height: .absolute(300)).scrollView().showsHorizontalScrollIndicator(false)
      }.inset(v: 10).styleColor(.systemGroupedBackground).id("Waterfall1")
      
      VStack(spacing: 10) {
        Text("Vertical waterfall").inset(left: 10)
        Waterfall(columns: 3, spacing: 5) {
          for (index, data) in self.waterfallData.enumerated() {
            let size = data.size
            Space().size(width: .fill, height: .aspectPercentage(size.height/size.width)).styleColor(data.color).overlay(Text("\(index)").textAlignment(.center))
          }
        }.inset(h: 10).size(width: .fill)
      }.inset(v: 10).styleColor(.systemGroupedBackground).id("Waterfall2")
      
    }.inset(20)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
  @objc func resetIds() {
    horizontalData = ComplexLayoutViewController.defaultHorizontalData.shuffled()
  }
  
  @objc func shuffled() {
    horizontalData = horizontalData.shuffled()
  }
  
  func showAlert() {
    let alertController = UIAlertController(title: "Tag",
                                            message: "Create new label",
                                            preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: nil)
    alertController.addAction(cancelAction)
    
    let confirmAction = UIAlertAction(
      title: "Confirm",
      style: .default,
      handler: { action in
        guard let textField = (alertController.textFields?.first), let text = textField.text, !text.isEmpty else { return }
        self.tags.append((text, ComplexLayoutViewController.colors.randomElement()!))
      })
    alertController.addAction(confirmAction)
    alertController.addTextField { textField in
      textField.placeholder = "Enter new tag name"
    }
    
    present(alertController,
            animated: true,
            completion: nil)
    
  }
  
}
