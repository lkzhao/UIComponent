//
//  ViewController.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//
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

		let viewProvider = FillViewProvider(view: {
			let v = UIView()
			v.backgroundColor = .red
			return v
		}())
		let provider = InsetLayout(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), child: viewProvider)
		//    collectionView.provider = DemoProvider() //InfiniteListProvider()
		collectionView.provider = provider

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

class DemoProvider: Provider {
	func layout(size: CGSize) -> CGSize {
		return CGSize(width: size.width, height: size.height * 2)
	}

	func views(in _: CGRect) -> [(ViewProvider, CGRect)] {
		return [
			(DemoViewProvider(), CGRect(x: 0, y: 0, width: 100, height: 200)),
			(DemoViewProvider(), CGRect(x: 0, y: 300, width: 100, height: 200)),
		]
	}
}

class DemoViewProvider: ViewProvider {
	var key: String = UUID().uuidString

	var animator: Animator?

	func makeView() -> UIView {
		let v = UIView()
		v.backgroundColor = .red
		return v
	}

	func updateView(_: UIView) {
		// print("update view")
	}

	func layout(size _: CGSize) -> CGSize {
		return CGSize(width: 40, height: 60)
	}

	func views(in _: CGRect) -> [(ViewProvider, CGRect)] {
		return []
	}
}
