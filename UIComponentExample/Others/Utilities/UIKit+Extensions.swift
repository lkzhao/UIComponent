//
//  UIFont.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

extension UIFont {
    static let title = UIFont.boldSystemFont(ofSize: 32)
    static let subtitle = UIFont.boldSystemFont(ofSize: 20)
    static let bodyBold = UIFont.boldSystemFont(ofSize: 16)
    static let body = UIFont.systemFont(ofSize: 16)
    static let caption = UIFont.systemFont(ofSize: 14)
}

extension UIColor {
    static let secondaryLabel = UIColor.label.withAlphaComponent(0.6)
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
