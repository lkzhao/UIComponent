//
//  CustomViewExample.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 8/23/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

struct CardData {
  let id: String = "card-\(UUID().uuidString)"
  let title: String
  let subtitle: String
}

class CardView: UIView {
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 22)
    return label
  }()
  let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  var data: CardData? {
    didSet {
      titleLabel.text = data?.title
      subtitleLabel.text = data?.subtitle
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = CGRect(x: 20, y: 10, width: bounds.width - 40, height: 40)
    subtitleLabel.frame = CGRect(x: 20, y: 50, width: bounds.width - 40, height: 40)
  }
}

struct Card: ViewComponent {
  let data: CardData
  func layout(_ constraint: Constraint) -> CardViewRenderer {
    CardViewRenderer(data: data, size: CGSize(width: constraint.maxSize.width, height: 100))
  }
}

struct CardViewRenderer: ViewRenderer {
  let data: CardData
  var id: String? {
    data.id
  }
  let size: CGSize
  func updateView(_ view: CardView) {
    view.data = data
  }
}
