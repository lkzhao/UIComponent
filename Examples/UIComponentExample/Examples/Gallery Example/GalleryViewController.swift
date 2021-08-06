//
//  GalleryViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/29.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

class GalleryViewController: ComponentViewController {
  
  var verticalData: [GalleryItemData] = (0...33).map { _ in GalleryItemData() } {
    didSet {
      reloadComponent()
    }
  }
  
  let horizontalData: [GalleryItemData] = (0...33).map { _ in GalleryItemData() }
  
  let positionExampleData = (1...6).map { _ in GalleryItemData() }
  
  
  override var component: Component {
    VStack(spacing: 20) {
      Text("Gallery layouts", font: .boldSystemFont(ofSize: 20)).size(width: .fill).inset(h: 20)
      HStack(spacing: 20) {
        for layout in GalleryFrames.LayoutType.allCases {
          let template = GalleryFrames(layout: layout)
          HorizontalGallery(spacing: 5, template: [template]) {
            for index in 0 ..< template.calculateFrames(spacing: 0, side: 0, makeFrame: { _, _ in .zero }).count {
              Space().styleColor(.systemBlue).overlay(GalleryIndexOverlay(index: index))
            }
          }
        }
      }.inset(h: 20).size(height: UIScreen.main.bounds.width - 40).scrollView()
      
      for layout in GalleryFrames.LayoutType.allCases {
        VStack(spacing: 10) {
          Text(".\(layout)")
          let template = GalleryFrames(layout: layout)
          VerticalGallery(spacing: 5, template: [template]) {
            for index in 0 ..< template.calculateFrames(spacing: 0, side: 0, makeFrame: { _, _ in .zero }).count {
              Space().styleColor(.systemBlue).overlay(GalleryIndexOverlay(index: index))
            }
          }
        }.inset(h: 20)
      }
      
      Text("Flow horizontal gallery").inset(h: 20)
      
      let temolates = GalleryFrames.LayoutType.allCases.map{ GalleryFrames(layout: $0) }
      
      HorizontalGallery(spacing: 2, template: temolates) {
        for data in horizontalData {
          GalleryItem(data: data)
        }
      }.inset(h: 20).size(height: UIScreen.main.bounds.width - 40).scrollView().showsHorizontalScrollIndicator(false)
      
      Text("Flow horizontal gallery").inset(h: 20)
      
      VerticalGallery(spacing: 2, template: temolates) {
        for data in verticalData {
          GalleryItem(data: data)
        }
      }
      
    }.inset(v: 20)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
}
