//
//  ViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

class ViewController<View: UIView>: UIViewController {
    var rootView: View {
        view as! View
    }

    public init(rootView: View = View()) {
        super.init(nibName: nil, bundle: nil)
        self.view = rootView
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.view = View()
    }
}
