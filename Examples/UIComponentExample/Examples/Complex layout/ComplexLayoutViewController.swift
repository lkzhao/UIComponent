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
  
  var tags: [(String, UIColor)] = [("SwiftUI", .systemRed),
                                   ("Hello", .systemOrange),
                                   ("UIComponent", .systemPink),
                                   ("Vue", .systemGreen),
                                   ("Flex Layout", .systemTeal)] {
    didSet {
      reloadComponent()
    }
  }
  
  var expand = false
  
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
      Text("Complex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill).id("label")
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
        }.id("2")
      }
      
      IntroductionCard(expand: expand) { [weak self] value in
        self?.expand = !value
        self?.reloadComponent()
      }
      
      Text("Tag view", font: .boldSystemFont(ofSize: 20)).id("label2")
      VStack(spacing: 10) {
        Text("Tags row")
        Flow(spacing: 5, alignItems: .center) {
          if tags.isEmpty {
            Text("Empty Tag")
          } else {
            for (index, tag) in tags.enumerated() {
              Text(tag.0, font: .systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.1).tappableView { [weak self] in
                guard let self = self else { return }
                self.tags.remove(at: index)
              }.id(tag.0)
            }
          }
          HStack(alignItems: .center) {
            Image(systemName: "plus")
            Text("Add new", font: .systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
          }.inset(h: 10, v: 5).styleColor(.systemGray5).tappableView {
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
              Text(tag.0, font: .systemFont(ofSize: 14, weight: .regular)).textColor(.label).inset(h: 10, v: 5).styleColor(tag.1).tappableView { [weak self] in
                guard let self = self else { return }
                self.tags.remove(at: index)
              }.id(tag.0)
            }
          }
          HStack(alignItems: .center) {
            Image(systemName: "plus")
            Text("Add new", font: .systemFont(ofSize: 14, weight: .regular)).textColor(.systemBlue)
          }.inset(h: 10, v: 5).styleColor(.systemGray5).tappableView {
            self.showAlert()
          }
        }.size(height: 150).view().with(\.animator, AnimatedReloadAnimator())
        
        Text("Shuffled tags").textColor(.systemBlue).tappableView { [weak self] in
          guard let self = self else {return}
          self.tags = self.tags.shuffled()
        }
      }.inset(10).styleColor(.systemGroupedBackground).id("tag")
      
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
        }.inset(h: 10).inset(top: 5).scrollView().showsHorizontalScrollIndicator(false).with(\.animator, AnimatedReloadAnimator())
        HStack(spacing: 10) {
          SimpleViewComponent<UIButton>(view: resetButton).isEnabled(self.ids.count != 5)
          SimpleViewComponent<UIButton>(view: shuffledBuuton).isEnabled(self.ids.count != 0)
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
            let size = data.0
            Space().size(width: .fill, height: .aspectPercentage(size.height/size.width)).styleColor(data.1).overlay(Text("\(index)").textAlignment(.center))
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
    ids = ComplexLayoutViewController.originalIds.shuffled()
  }
  
  @objc func shuffled() {
    ids = ids.shuffled()
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
