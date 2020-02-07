//
//  ClosureViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class ClosureViewProvider<View: UIView>: ViewAdapter<View> {
  public typealias ViewGenerator = () -> View
  public typealias ViewUpdater = (View) -> Void
  public typealias SizeGenerator = (CGSize) -> CGSize
  
  public var viewGenerator: ViewGenerator?
  public var viewUpdater: ViewUpdater?
  public var sizeSource: SizeGenerator?
  
  public init(key: String = UUID().uuidString,
              animator: Animator? = nil,
              reuseManager: CollectionReuseManager? = nil,
              generate: ViewGenerator? = nil,
              update: ViewUpdater?,
              size: SizeGenerator?) {
    super.init(key: key, animator: animator, reuseManager: reuseManager)
    self.viewGenerator = generate
    self.viewUpdater = update
    self.sizeSource = size
  }
  
  open override func updateView(_ view: View) {
    viewUpdater?(view)
  }
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    return sizeSource?(size) ?? .zero
  }
  
  open override func makeView() -> View {
    return viewGenerator?() ?? View()
  }
}
