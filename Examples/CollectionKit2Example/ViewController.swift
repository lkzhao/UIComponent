//
//  ViewController.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import CollectionKit2
import UIKit

class ViewController: UIViewController {
	let collectionView = CollectionView()

	let reloadButton: UIButton = {
		let button = UIButton()
		button.setTitle("Reload", for: .normal)
		button.titleLabel?.font = .boldSystemFont(ofSize: 20)
		button.backgroundColor = UIColor(hue: 0.6, saturation: 0.68, brightness: 0.98, alpha: 1)
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: -12)
		button.layer.shadowRadius = 10
		button.layer.shadowOpacity = 0.1
		return button
	}()

	var currentDataIndex = 0
	var data: [[Int]] = [
		[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
		[2, 3, 5, 8, 10],
		[8, 9, 10, 11, 12, 13, 14, 15, 16],
		[],
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(collectionView)
		reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
		view.addSubview(reloadButton)

		let viewProvider1 = FillViewProvider(view: {
			let v = UIView()
			v.backgroundColor = .red
			return v
		}())

		let viewProvider2 = ClosureViewProvider(generate: { () -> UIView in
			UIView()
		}, update: { view in
			view.backgroundColor = .blue
		}) { (_) -> CGSize in
			CGSize(width: 100, height: 200)
		}

		let viewProvider = FlowLayout(children: [viewProvider1, viewProvider2])
		let provider = InsetLayout(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
															 child: HalfSizeProvider(provider: HalfSizeProvider(provider: HalfSizeProvider(provider: viewProvider1))))

		let provider2 = viewProvider
    let v0 = UIView()
    v0.backgroundColor = .black
    let v1 = UIView()
    v1.backgroundColor = .red
    let v2 = UIView()
    v2.backgroundColor = .blue
    let v3 = UIView()
    v3.backgroundColor = .green

//    collectionView.provider = ColumnLayout {
//      RowLayout {
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v1)
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v2)
//      }
//      RowLayout {
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: UIView())
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: UIView())
//      }
//    }
    
//    collectionView.provider = ColumnLayout {
//      ForEach(data[0]) { number in
//        ClosureViewProvider(update: { (view: UILabel) in
//          view.text = "\(number)"
//        }, size: { _ in
//          CGSize(width: 100, height: 100)
//        })
//      }
//    }

    let showV1 = true
    collectionView.provider = ColumnLayout {
      RowLayout {
        ForEach(0..<5) { number in
          LabelProvider(text: "\(number)")
          LabelProvider(text: "LOL")
        }
      }
      SimpleViewProvider(width: .absolute(200), height: .absolute(100), view: v0)
      if showV1 {
        SimpleViewProvider(width: .absolute(200), height: .absolute(100), view: v1)
      }
    }
    
    
//    let shouldDisplayFirstRow = true
//    collectionView.provider = ColumnLayout {
//      if shouldDisplayFirstRow {
//        SimpleViewProvider(width: .absolute(200), height: .absolute(100), view: v0)
//      }
//      RowLayout {
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v1)
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v2)
//      }
//      SimpleViewProvider(width: .absolute(200), height: .absolute(100), view: v3)
//    }

//		let animator = AnimatedReloadAnimator(entryTransform: AnimatedReloadAnimator.fancyEntryTransform)
//		collectionView.animator = animator
//
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//			self.collectionView.provider = provider2
//		}

		collectionView.isScrollEnabled = true
		collectionView.alwaysBounceVertical = true
	}

	@objc func reload() {
		collectionView.setNeedsReload()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame = view.bounds
		reloadButton.frame = CGRect(x: 0, y: view.bounds.height - 60,
																width: view.bounds.width, height: 60)
	}
}

class LabelProvider: BaseViewProvider<UILabel> {
  var text: String
  var font: UIFont
  init(text: String, font: UIFont = UIFont.systemFont(ofSize: 16)) {
    self.text = text
    self.font = font
    super.init()
  }
  override func updateView(_ view: UILabel) {
    view.font = font
    view.text = text
  }
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return (text as NSString).boundingRect(with: size, options: [], attributes: [.font: font], context: nil).size
  }
}

class HalfSizeProvider: Provider {
	private let provider: Provider
	init(provider: Provider) {
		self.provider = provider
	}

	var _size: CGSize = .zero
	func layout(size: CGSize) -> CGSize {
		_size = provider.layout(size: CGSize(width: size.width, height: size.height / 2))
		return _size
	}

	func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
		print("frame: \(frame)")
		return provider.views(in: CGRect(origin: .zero, size: _size)).map { viewProvider, frame in
			(viewProvider, frame)
		}
	}
}
