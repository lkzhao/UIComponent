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
  
  static let defaultHorizontalListData: [HorizontalCardItem.Context] = (0..<10).map { _ in
    HorizontalCardItem.Context()
  }
  
  var horizontalListData = defaultHorizontalListData {
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
  
  lazy var resetButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Reset", for: .normal)
    button.addTarget(self, action: #selector(resetHorizontalListData), for: .touchUpInside)
    return button
  }()
  
  lazy var shuffleButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Shuffle", for: .normal)
    button.addTarget(self, action: #selector(shuffleHorizontalListData), for: .touchUpInside)
    return button
  }()
  
  override var component: Component {
    VStack(spacing: 20) {
      Text("Complex layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill).id("label")
      VStack(spacing: 10) {
        UserProfile(avatar: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640",
                    userName: "Jack",
                    introduce: "This is simply amazing")
        if showWeather {
          HStack(justifyContent: .end, alignItems: .center) {
            Text("Weather forecast: ")
            HStack(spacing: 10) {
              Image(systemName: "sun.dust")
              Image(systemName: "sun.haze")
              Image(systemName: "cloud.bolt.rain.fill")
            }.inset(5).styleColor(.systemGroupedBackground)
          }
        }
        Text(showWeather ? "Hide weather" : "Show weather").textColor(.systemBlue).tappableView { [unowned self] in
          self.showWeather.toggle()
        }.id("weather-toggle")
      }

      IntroductionCard(isExpanded: isExpanded) { [unowned self] in
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
            self.didTapAddTag()
          }
        }.view().with(\.animator, AnimatedReloadAnimator())
        Separator()
        Text("Tags column")
        FlexColumn(spacing: 5) {
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
            self.didTapAddTag()
          }
        }.size(height: 130).view().with(\.animator, AnimatedReloadAnimator())
        
        Text("Shuffle tags").textColor(.systemBlue).tappableView { [unowned self] in
          self.tags = self.tags.shuffled()
        }
      }.inset(10).styleColor(.systemGroupedBackground).id("tag")
      
      VStack(spacing: 10) {
        Text("Horizontal list").inset(left: 10)
        HStack(spacing: 10, alignItems: .center) {
          if horizontalListData.isEmpty {
            Text("No data here", font: .systemFont(ofSize: 17, weight: .medium)).flex()
          } else {
            for (offset, element) in horizontalListData.enumerated() {
              HorizontalCardItem(data: element).tappableView { [unowned self] in
                self.horizontalListData.remove(at: offset)
              }
            }
          }
        }.inset(top: 5, left: 10, bottom: 0, right: 10).visibleInset(-200).scrollView().onFirstReload { scrollView in
          let cellFrame = scrollView.frame(id: ComplexLayoutViewController.defaultHorizontalListData[5].id)!
          scrollView.scrollRectToVisible(CGRect(center: cellFrame.center, size: scrollView.bounds.size), animated: false) // scroll to item 5 as the center
        }.showsHorizontalScrollIndicator(false).with(\.animator, AnimatedReloadAnimator())
        HStack(spacing: 10) {
          SimpleViewComponent<UIButton>(view: resetButton).isEnabled(horizontalListData != ComplexLayoutViewController.defaultHorizontalListData).id("reset")
          SimpleViewComponent<UIButton>(view: shuffleButton).isEnabled(!horizontalListData.isEmpty).id("shuffled")
        }.inset(left: 10)
      }.inset(v: 10).styleColor(.systemGroupedBackground).id("horizontal")
      
      Text("Badges", font: .boldSystemFont(ofSize: 20)).id("label3")
      VStack(spacing: 10) {
        Text("Badges custom offset")
        Flow(spacing: 10) {
          Box().badge(NumberBadge(1), offset: .zero)
          Box().badge(NumberBadge("99+"), offset: CGVector(dx: 5, dy: -5))
          Box().badge(NumberBadge.redPoint(), offset: CGVector(dx: -5, dy: 5))
          Space(width: 50, height: 50).badge(BannerBadge("New"), horizontalAlignment: .stretch, offset: CGVector(dx: 0, dy: 2)).styleColor(.systemBlue).clipsToBounds(true)
          Space(width: 50, height: 50).badge(BannerBadge("New"), verticalAlignment: .end, horizontalAlignment: .stretch, offset: CGVector(dx: 0, dy: -2)).styleColor(.systemBlue).clipsToBounds(true)
        }
        Text("Badges position")
        Flow(spacing: 10) {
          for v in CrossAxisAlignment.allCases {
            for h in CrossAxisAlignment.allCases {
              Box().badge(NumberBadge.redPoint(), verticalAlignment: v, horizontalAlignment: h)
            }
          }
        }
      }.inset(10).styleColor(.systemGroupedBackground).id("badges")
      
    }.inset(20)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
  @objc func resetHorizontalListData() {
    horizontalListData = ComplexLayoutViewController.defaultHorizontalListData
  }
  
  @objc func shuffleHorizontalListData() {
    horizontalListData = horizontalListData.shuffled()
  }
  
  func didTapAddTag() {
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
      handler: { [unowned self] action in
        guard let textField = (alertController.textFields?.first), let text = textField.text, !text.isEmpty else { return }
        self.tags.append((text, .randomSystemColor()))
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
