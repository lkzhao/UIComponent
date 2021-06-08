//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/8/21.
//

import UIKit

public struct TappableViewConfiguration {
  public static var `default` = TappableViewConfiguration(onHighlightChanged: nil)
  
  // place to apply highlight state or animation to the TappableView
  public var onHighlightChanged: ((TappableView, Bool) -> Void)?
  
  public init(onHighlightChanged: ((TappableView, Bool) -> Void)?) {
    self.onHighlightChanged = onHighlightChanged
  }
}

open class TappableView: ComponentView {
  public var onTap: ((TappableView) -> Void)?
  public var configuration: TappableViewConfiguration?

  open var isHighlighted: Bool = false {
    didSet {
      guard isHighlighted != oldValue else { return }
      let config = configuration ?? TappableViewConfiguration.default
      config.onHighlightChanged?(self, isHighlighted)
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    accessibilityTraits = .button
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    isHighlighted = true
  }

  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    isHighlighted = false
  }

  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    isHighlighted = false
  }

  @objc open func didTap() {
    onTap?(self)
  }
}

extension Component {
  public func tappableView(id: String = UUID().uuidString,
                           configuration: TappableViewConfiguration? = nil,
                           _ onTap: @escaping (TappableView) -> Void) -> some ViewComponent {
    ComponentWrapperViewComponent<TappableView>(id: id, component: self).onTap(onTap).configuration(configuration)
  }
  public func tappableView(id: String = UUID().uuidString,
                           configuration: TappableViewConfiguration? = nil,
                           _ onTap: @escaping () -> Void) -> some ViewComponent {
    tappableView(id: id, configuration: configuration) { _ in
      onTap()
    }
  }
}
