//
//  TappableViewExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class TappableViewExamplesView: UIView {
    @Observable
    class TappableViewModel {
        var tapCount: Int = 0
        var doubleTapCount: Int = 0
        var longPressCount: Int = 0
        var lastTapLocation: String = "None"
        var isHighlighted: Bool = false
        var selectedItem: String? = nil
    }
    
    let viewModel = TappableViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("TappableView Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("What is tappableView?", font: .subtitle)
                Text("The .tappableView modifier makes any component interactive by wrapping it in a TappableView that responds to gestures like tap, double tap, and long press.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "hand.tap")
                            .contentMode(.center)
                            .tintColor(.systemBlue)
                            .size(width: 24, height: 24)
                        Text("Single tap, double tap, and long press", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "ellipsis.rectangle")
                            .contentMode(.center)
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        Text("Context menus and previews", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "sparkles")
                            .contentMode(.center)
                            .tintColor(.systemOrange)
                            .size(width: 24, height: 24)
                        Text("Custom highlight animations", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("Basic tap handling", font: .subtitle)
                Text("Add .tappableView modifier with a closure to handle taps. The closure can optionally receive the TappableView instance.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Simple tap handler", font: .caption)
                    Text("Taps: \(viewModel.tapCount)", font: .body).textColor(.secondaryLabel)
                    #CodeExampleNoInsets(
                        Text("Tap Me!", font: .body)
                            .inset(h: 20, v: 12)
                            .backgroundColor(.systemBlue)
                            .textColor(.white)
                            .cornerRadius(8)
                            .tappableView {
                                viewModel.tapCount += 1
                            }
                    )
                    
                    Text("Tap handler with view parameter", font: .caption)
                    Text("Last tap location: \(viewModel.lastTapLocation)", font: .body).textColor(.secondaryLabel)
                    #CodeExampleNoInsets(
                        Text("Tap for Location", font: .body)
                            .inset(h: 20, v: 12)
                            .backgroundColor(.systemGreen)
                            .textColor(.white)
                            .cornerRadius(8)
                            .tappableView { view in
                                let location = view.tapGestureRecognizer.location(in: view)
                                viewModel.lastTapLocation = "(\(Int(location.x)), \(Int(location.y)))"
                            }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Double tap", font: .subtitle)
                Text("Use .onDoubleTap modifier to handle double tap gestures. Chain it after .tappableView to add the gesture handler.", font: .body).textColor(.secondaryLabel)
                Text("Double taps: \(viewModel.doubleTapCount)", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    Text("Double Tap Me!", font: .body)
                        .inset(h: 20, v: 12)
                        .backgroundColor(.systemPurple)
                        .textColor(.white)
                        .cornerRadius(8)
                        .tappableView { _ in }
                        .onDoubleTap { _ in
                            viewModel.doubleTapCount += 1
                        }
                )
            }
            
            VStack(spacing: 10) {
                Text("Long press", font: .subtitle)
                Text("Use .onLongPress modifier to handle long press gestures. The closure receives both the view and the gesture recognizer, allowing you to track gesture states.", font: .body).textColor(.secondaryLabel)
                Text("Long presses: \(viewModel.longPressCount)", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    Text("Long Press Me!", font: .body)
                        .inset(h: 20, v: 12)
                        .backgroundColor(.systemOrange)
                        .textColor(.white)
                        .cornerRadius(8)
                        .tappableView { _ in }
                        .onLongPress { _, gesture in
                            if gesture.state == .began {
                                viewModel.longPressCount += 1
                            }
                        }
                )
            }
            
            VStack(spacing: 10) {
                Text("Context menu", font: .subtitle)
                Text("Display context menus on long press using .contextMenuProvider modifier. Return a UIMenu with your desired actions.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    Text("Long Press for Menu", font: .body)
                        .inset(h: 20, v: 12)
                        .backgroundColor(.systemIndigo)
                        .textColor(.white)
                        .cornerRadius(8)
                        .tappableView { _ in }
                        .contextMenuProvider { _ in
                            UIMenu(children: [
                                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                                    print("Copy selected")
                                },
                                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                                    print("Share selected")
                                },
                                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: [.destructive]) { _ in
                                    print("Delete selected")
                                }
                            ])
                        }
                )
            }
            
            VStack(spacing: 10) {
                Text("Context menu with preview", font: .subtitle)
                Text("Add a preview that appears when the user long presses using .previewProvider modifier. This creates a peek and pop experience.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    HStack(spacing: 10, alignItems: .center) {
                        Image(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
                            .tintColor(.systemBlue)
                        VStack(spacing: 4) {
                            Text("Preview Image", font: .bodyBold)
                            Text("Long press to preview", font: .caption).textColor(.secondaryLabel)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemGray6)
                    .cornerRadius(12)
                    .tappableView {
                        print("Tapped image")
                    }
                    .previewProvider {
                        let previewView = UIView()
                        previewView.backgroundColor = .systemBackground
                        previewView.componentEngine.component = VStack(spacing: 10) {
                            Image(systemName: "photo.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
                                .tintColor(.systemBlue)
                            Text("This is a preview!", font: .title)
                        }.inset(40)
                        let vc = UIViewController()
                        vc.view = previewView
                        vc.preferredContentSize = CGSize(width: 300, height: 300)
                        return vc
                    }
                    .contextMenuProvider { _ in
                        UIMenu(children: [
                            UIAction(title: "View Full Size", image: UIImage(systemName: "arrow.up.left.and.arrow.down.right")) { _ in
                                print("View full size")
                            }
                        ])
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("⚠️ Avoiding retain cycles", font: .subtitle)
                Text("When capturing self in TappableView closures, use weak or unowned references to prevent retain cycles and memory leaks.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    VStack(spacing: 6) {
                        Text("❌ Bad: Strong reference", font: .bodyBold).textColor(.systemRed)
                        Text("This creates a retain cycle because the view retains the component, which retains the closure, which retains self, which retains the view.", font: .body).textColor(.systemRed)
                        Code {
                            """
                            class MyView: UIView {
                                var count = 0 {
                                    didSet {
                                        setNeedsUpdateProperties()
                                    }
                                }
                                
                                override func updateProperties() {
                                    super.updateProperties()
                                    componentEngine.component = Text("Tap Me")
                                        .tappableView {
                                            // BAD: Strong capture of self
                                            self.count += 1
                                        }
                                }
                            }
                            """
                        }
                    }.inset(16).backgroundColor(.systemRed.withAlphaComponent(0.1)).cornerRadius(12)
                    
                    VStack(spacing: 6) {
                        Text("✅ Good: Weak reference", font: .bodyBold).textColor(.systemGreen)
                        Text("Use [weak self] to break the retain cycle. Check if self is still alive before using it.", font: .body).textColor(.systemGreen)
                        Code {
                            """
                            class MyView: UIView {
                                var count = 0 {
                                    didSet {
                                        setNeedsUpdateProperties()
                                    }
                                }
                                
                                override func updateProperties() {
                                    super.updateProperties()
                                    componentEngine.component = Text("Tap Me")
                                        .tappableView { [weak self] in
                                            guard let self else { return }
                                            self.count += 1
                                        }
                                }
                            }
                            """
                        }
                    }.inset(16).backgroundColor(.systemGreen.withAlphaComponent(0.1)).cornerRadius(12)
                    
                    VStack(spacing: 6) {
                        Text("Alternative: Unowned reference", font: .bodyBold)
                        Text("Use [unowned self] if you're certain self will outlive the closure. This is common when the component is rebuilt on every update.", font: .body).textColor(.secondaryLabel)
                        Code {
                            """
                            override func updateProperties() {
                                super.updateProperties()
                                componentEngine.component = Text("Tap Me")
                                    .tappableView { [unowned self] in
                                        self.count += 1
                                    }
                            }
                            """
                        }
                    }.inset(16).backgroundColor(.systemBlue.withAlphaComponent(0.1)).cornerRadius(12)
                    
                    VStack(spacing: 6) {
                        Text("💡 Pro Tip: Use local variables", font: .bodyBold).textColor(.systemIndigo)
                        Text("When working with Observable view models, capture them as local variables to avoid needing [weak self] or [unowned self].", font: .body).textColor(.secondaryLabel)
                        Code {
                            """
                            @Observable
                            class ViewModel {
                                var count = 0
                            }
                            
                            let viewModel = ViewModel()
                            
                            override func updateProperties() {
                                super.updateProperties()
                                let viewModel = viewModel  // Local copy
                                componentEngine.component = Text("Tap Me")
                                    .tappableView {
                                        // No [weak self] needed!
                                        viewModel.count += 1
                                    }
                            }
                            """
                        }
                    }.inset(16).backgroundColor(.systemIndigo.withAlphaComponent(0.1)).cornerRadius(12)
                }
            }
            
            VStack(spacing: 10) {
                Text("Custom highlight animation", font: .subtitle)
                Text("Use TappableViewConfig to customize how views respond to touches. The onHighlightChanged callback lets you add custom animations or visual feedback.", font: .body).textColor(.secondaryLabel)
                Text("Highlighted: \(viewModel.isHighlighted ? "Yes" : "No")", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Scale animation", font: .caption)
                    #CodeExampleNoInsets(
                        Text("Press and Hold", font: .body)
                            .inset(h: 20, v: 12)
                            .backgroundColor(.systemPink)
                            .textColor(.white)
                            .cornerRadius(8)
                            .tappableView {
                                print("Tapped!")
                            }
                            .tappableViewConfig(TappableViewConfig(
                                onHighlightChanged: { view, isHighlighted in
                                    viewModel.isHighlighted = isHighlighted
                                    UIView.animate(withDuration: 0.2) {
                                        view.transform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                                    }
                                }
                            ))
                    )
                    
                    Text("Opacity animation", font: .caption)
                    #CodeExampleNoInsets(
                        Text("Fade on Touch", font: .body)
                            .inset(h: 20, v: 12)
                            .backgroundColor(.systemTeal)
                            .textColor(.white)
                            .cornerRadius(8)
                            .tappableView {
                                print("Tapped!")
                            }
                            .tappableViewConfig(TappableViewConfig(
                                onHighlightChanged: { view, isHighlighted in
                                    UIView.animate(withDuration: 0.15) {
                                        view.alpha = isHighlighted ? 0.5 : 1.0
                                    }
                                }
                            ))
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Global TappableView configuration", font: .subtitle)
                Text("Set TappableViewConfig.default to apply a configuration to all TappableView instances in your app that don't have a specific configuration. This is useful for consistent highlight behavior across your entire UI.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Example: Global scale animation", font: .caption)
                    Code {
                        """
                        // Set this in your AppDelegate
                        TappableViewConfig.default = TappableViewConfig(
                            onHighlightChanged: { view, isHighlighted in
                                UIView.animate(withDuration: 0.2) {
                                    view.transform = isHighlighted 
                                        ? CGAffineTransform(scaleX: 0.95, y: 0.95) 
                                        : .identity
                                }
                            }
                        )
                        """
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Selectable list", font: .subtitle)
                Text("Combine tappableView with state management to create interactive lists with selection.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    VStack(alignItems: .stretch) {
                        for item in ["Swift", "UIKit", "SwiftUI", "Combine", "Core Data"] {
                            let isSelected = viewModel.selectedItem == item
                            HStack(spacing: 10, alignItems: .center) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .tintColor(isSelected ? .systemBlue : .systemGray3)
                                Text(item, font: .body)
                                    .textColor(isSelected ? .systemBlue : .label)
                            }
                            .inset(h: 16, v: 12)
                            .backgroundColor(isSelected ? .systemBlue.withAlphaComponent(0.1) : .clear)
                            .tappableView {
                                viewModel.selectedItem = item
                            }
                        }
                    }.size(width: 200)
                )
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Interactive card", font: .subtitle)
                Text("Create cards with multiple actions using both tap and context menu.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    VStack(spacing: 12) {
                        HStack(spacing: 10, alignItems: .center) {
                            Image(systemName: "doc.text.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
                                .tintColor(.systemBlue)
                            VStack(spacing: 4) {
                                Text("Document.pdf", font: .bodyBold)
                                Text("2.5 MB • Modified today", font: .caption)
                                    .textColor(.secondaryLabel)
                            }
                            .flex()
                            Image(systemName: "chevron.right")
                                .tintColor(.tertiaryLabel)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemGray6)
                    .cornerRadius(12)
                    .tappableView {
                        print("Open document")
                    }
                    .contextMenuProvider { _ in
                        UIMenu(children: [
                            UIAction(title: "Open", image: UIImage(systemName: "doc.text")) { _ in
                                print("Open")
                            },
                            UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                                print("Share")
                            },
                            UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { _ in
                                print("Rename")
                            },
                            UIAction(title: "Move", image: UIImage(systemName: "folder")) { _ in
                                print("Move")
                            },
                            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: [.destructive]) { _ in
                                print("Delete")
                            }
                        ])
                    }
                    .tappableViewConfig(TappableViewConfig(
                        onHighlightChanged: { view, isHighlighted in
                            UIView.animate(withDuration: 0.2) {
                                view.backgroundColor = isHighlighted ? UIColor.systemGray5 : UIColor.systemGray6
                            }
                        }
                    ))
                )
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Button grid", font: .subtitle)
                Text("Create a grid of tappable buttons with different actions.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    Flow(spacing: 10) {
                        for (icon, label) in [
                            ("photo", "Photos"),
                            ("music.note", "Music"),
                            ("video", "Videos"),
                            ("doc", "Files"),
                            ("location", "Maps"),
                            ("message", "Messages")
                        ] {
                            VStack(spacing: 8, justifyContent: .center, alignItems: .center) {
                                Image(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
                                    .tintColor(.systemBlue)
                                Text(label, font: .caption)
                            }
                            .inset(20)
                            .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                            .cornerRadius(12)
                            .size(width: 120, height: 100)
                            .tappableView {
                                print("\(label) tapped")
                            }
                            .tappableViewConfig(TappableViewConfig(
                                onHighlightChanged: { view, isHighlighted in
                                    UIView.animate(withDuration: 0.15) {
                                        view.transform = isHighlighted ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
                                        view.alpha = isHighlighted ? 0.7 : 1.0
                                    }
                                }
                            ))
                        }
                    }.size(width: 380).inset(10)
                )
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().delaysContentTouches(false).contentInsetAdjustmentBehavior(.always).fill()
    }
}

