//
//  UserProfile.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import Kingfisher
import UIKit.UIImageView

extension Component {
  fileprivate func shadowAvatar() -> ViewUpdateComponent<ComponentDisplayableViewComponent<ComponentView>> {
    view().update{
      $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
      $0.layer.shadowOffset = CGSize(width: 0, height: 3)
      $0.layer.shadowRadius = 6
      $0.layer.shadowOpacity = 1
    }
  }
}

struct UserProfile: ComponentBuilder {
  
  let avatar: String
  let userName: String
  let introduce: String
  let gender: String
  let showWeather: Bool
  
  func build() -> Component {
    VStack(spacing: 5) {
      HStack(spacing: 10, alignItems: .center) {
        SimpleViewComponent<UIImageView>().update{$0.kf.setImage(with: URL(string: avatar), placeholder: UIImage(systemName: "person.circle.fill"))}
          .contentMode(.scaleAspectFill)
          .clipsToBounds(true)
          .size(width: 100, height: .aspectPercentage(1))
          .update{$0.layer.cornerRadius = $0.frame.height/2}
          .with(\.layer.borderWidth, 2)
          .with(\.layer.borderColor, UIColor.white.cgColor)
          .shadowAvatar()
        HStack(spacing: 5, justifyContent: .spaceBetween, alignItems: .center) {
          VStack(spacing: 5) {
            Text(userName)
            HStack(justifyContent: .spaceBetween, alignItems: .center) {
              Text(introduce.isEmpty ? "introduce myself..." : introduce, font: .systemFont(ofSize: 13, weight: .light)).textColor(.secondaryLabel)
              Image(systemName: "chevron.right")
            }
            Text("gender: \(gender)").font(.systemFont(ofSize: 12, weight: .light)).textColor(.secondaryLabel)
          }.flex()
        }.flex()
      }.inset(15).styleColor(.systemGroupedBackground)//.flex()
      if showWeather {
        HStack(justifyContent: .spaceEvenly, alignItems: .center) {
          Spacer()
          Text("Weather forecast: ")
          HStack/* Can also be used this way HStack(spacing: 10) */ {
            Join {
              Image(systemName: "sun.dust")
              Image(systemName: "sun.haze")
              Image(systemName: "cloud.bolt.rain.fill")
            } separator: {
              Space(width: 10)
            }
          }.inset(h: 5, v: 5).styleColor(.systemGroupedBackground)
        }
      }
    }.inset(5)
  }
}
