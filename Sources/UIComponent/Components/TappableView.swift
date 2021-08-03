//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/8/21.
//

import UIKit

public struct TappableViewConfiguration {
  public static var `default` = TappableViewConfiguration(onHighlightChanged: nil, didTap: nil)
  
  // place to apply highlight state or animation to the TappableView
  public var onHighlightChanged: ((TappableView, Bool) -> Void)?
  
  // hook before the actual onTap is called
  public var didTap: ((TappableView) -> Void)?
  
  public init(onHighlightChanged: ((TappableView, Bool) -> Void)? = nil, didTap: ((TappableView) -> Void)? = nil) {
    self.onHighlightChanged = onHighlightChanged
    self.didTap = didTap
  }
}

open class TappableView: ComponentView {
  public var configuration: TappableViewConfiguration?
  
  lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
  lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
  lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)
  
  public var previewBackgroundColor: UIColor?
  public var onTap: ((TappableView) -> Void)? {
    didSet {
      if onTap != nil {
        addGestureRecognizer(tapGestureRecognizer)
      } else {
        removeGestureRecognizer(tapGestureRecognizer)
      }
    }
  }
  
  public var onLongPress: ((TappableView) -> Void)? {
    didSet {
      if onLongPress != nil {
        addGestureRecognizer(longPressGestureRecognizer)
      } else {
        removeGestureRecognizer(longPressGestureRecognizer)
      }
    }
  }
  
  public var previewProvider: (() -> UIViewController?)? {
    didSet {
      if previewProvider != nil || contextMenuProvider != nil {
        addInteraction(contextMenuInteraction)
      } else {
        removeInteraction(contextMenuInteraction)
      }
    }
  }
  
  public var onCommitPreview: ((UIContextMenuInteractionCommitAnimating) -> Void)?
  
  public var contextMenuProvider: (() -> UIMenu?)? {
    didSet {
      if previewProvider != nil || contextMenuProvider != nil {
        addInteraction(contextMenuInteraction)
      } else {
        removeInteraction(contextMenuInteraction)
      }
    }
  }

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
    let config = configuration ?? TappableViewConfiguration.default
    config.didTap?(self)
    onTap?(self)
  }
  
  @objc open func didLongPress() {
    if longPressGestureRecognizer.state == .began {
      onLongPress?(self)
    }
  }
}

extension TappableView: UIContextMenuInteractionDelegate {
  public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    if let previewProvider = previewProvider {
      return UIContextMenuConfiguration(identifier: nil) {
        previewProvider()
      } actionProvider: { [weak self] _ in
        return self?.contextMenuProvider?()
      }
    } else {
      return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
        return self?.contextMenuProvider?()
      }
    }
  }
  
  public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    if let previewBackgroundColor = previewBackgroundColor {
      let param = UIPreviewParameters()
      param.backgroundColor = previewBackgroundColor
      return UITargetedPreview(view: self, parameters: param)
    }
    return nil
  }
  
  public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    if let onCommitPreview = onCommitPreview {
      onCommitPreview(animator)
    } else {
      animator.addAnimations {
        self.onTap?(self)
      }
    }
  }
}

extension Component {
  public func tappableView(configuration: TappableViewConfiguration? = nil,
                           _ onTap: @escaping (TappableView) -> Void) -> ViewUpdateComponent<ComponentDisplayableViewComponent<TappableView>> {
    ComponentDisplayableViewComponent<TappableView>(component: self).update {
      $0.onTap = onTap
      $0.configuration = configuration
    }
  }
  public func tappableView(configuration: TappableViewConfiguration? = nil,
                           _ onTap: @escaping () -> Void) -> ViewUpdateComponent<ComponentDisplayableViewComponent<TappableView>> {
    tappableView(configuration: configuration) { _ in
      onTap()
    }
  }
}
