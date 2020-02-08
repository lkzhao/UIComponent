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
	var collectionView = CollectionView()

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

    let v0 = UIView()
    v0.backgroundColor = .black
    let v1 = UIView()
    v1.backgroundColor = .red
    let v2 = UIView()
    v2.backgroundColor = .blue
    let v3 = UIView()
    v3.backgroundColor = .green

//    collectionView.provider = VStack {
//      HStack {
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v1)
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: v2)
//      }
//      HStack {
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: UIView())
//        SimpleViewProvider(width: .absolute(100), height: .absolute(100), view: UIView())
//      }
//    }
    
//    collectionView.provider = VStack {
//      ForEach(data[0]) { number in
//        ClosureViewProvider(update: { (view: UILabel) in
//          view.text = "\(number)"
//        }, size: { _ in
//          CGSize(width: 100, height: 100)
//        })
//      }
//    }
    
//    collectionView.provider = VStack {
//      HStack {
//        Text("FLEX").color(.red).padding(20).view().backgroundColor(.black).flex()
//        ForEach(0..<5) { number in
//          VStack(alignItems: .center) {
//            Text("\(number)")
//            VSpace(50)
//            Text("LOL").padding(10)
//          }
//        }
//      }
//      ViewAdapter(view: v1).size(width: .fill, height: .absolute(50.0))
//      ViewAdapter(view: v2).size(width: .fill, height: .absolute(50.0))
//    }

    struct User: ProviderWrapper {
      let name: String
      let image: UIImage
      
      var provider: Provider {
        HStack(alignItems: .center) {
          Image(image).tintColor(.darkGray)
          HSpace(10)
          Text(name)
          Flex()
        }.padding(20).view().backgroundColor(.white).cornerRadius(10).shadow(radius: 8)
      }
    }

    collectionView.provider = VStack(spacing: 10) {
      User(name: "John Appleseed", image: UIImage(systemName: "person")!)
      User(name: "Brian", image: UIImage(systemName: "person")!)
      User(name: "Josh", image: UIImage(systemName: "person")!)
      User(name: "Mason", image: UIImage(systemName: "person")!)
    }.padding(10)
    
//    collectionView.provider = InfiniteListProvider()

//    collectionView.provider = VStack(spacing: 10) {
//      ForEach(0..<5) { number in
//        Text("\(number)").backgroundColor(.red)
//        Text("LOL").backgroundColor(.green)
//      }
//    }
    
//    let showV1 = true
//    collectionView.provider = VStack {
//      FlowLayout {
//        User(name: "John Appleseed", image: UIImage(systemName: "person")!)
//        User(name: "Brian", image: UIImage(systemName: "person")!)
//        User(name: "Josh", image: UIImage(systemName: "person")!)
//        User(name: "Mason", image: UIImage(systemName: "person")!)
//      }
//      UILabel().then {
//        $0.font = UIFont.boldSystemFont(ofSize: 44)
//        $0.textColor = .white
//        $0.backgroundColor = .black
//        $0.text = "Raw Label"
//      }
//      if showV1 {
//        UILabel().then {
//          $0.text = "Oh my gosh"
//        }
//      }
//    }
    
    
//    let shouldDisplayFirstRow = true
//    collectionView.provider = VStack {
//      if shouldDisplayFirstRow {
//        SimpleViewProvider(width: .absolute(200), height: .absolute(100), view: v0)
//      }
//      HStack {
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
