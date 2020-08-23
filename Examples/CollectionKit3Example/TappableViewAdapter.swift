//
//  TappableViewAdapter.swift
//  CollectionKit3Example
//
//  Created by Luke Zhao on 8/22/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import UIKit
import CollectionKit3

class TappableView: CKView {
  var onTap: (() -> Void)? {
    didSet {
      if oldValue == nil, onTap != nil {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
      } else if onTap == nil, oldValue != nil {
        for gesture in gestureRecognizers ?? [] where gesture is UITapGestureRecognizer {
          removeGestureRecognizer(gesture)
        }
      }
    }
  }

  @objc func didTap() {
    onTap?()
  }
}
