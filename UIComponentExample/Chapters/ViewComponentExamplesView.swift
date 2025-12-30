//  Created by Luke Zhao on 11/5/25.

import UIComponent

class ViewComponentExamplesView: UIView {

    let existingSwitch = UISwitch()
    let existingSwitch2 = UISwitch()

    var isEnabled: Bool = false {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("ViewComponent Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("What is ViewComponent?", font: .subtitle)
                Text("ViewComponent wraps any UIView to use within UIComponent layouts. It enables you to use standard UIKit views (UIButton, UITextField, etc.) or custom views alongside declarative components.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "puzzlepiece.extension")
                            .contentMode(.center)
                            .tintColor(.systemBlue)
                            .size(width: 24, height: 24)
                        Text("Integrate any UIView", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .contentMode(.center)
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        Text("Automatic view reuse", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "bolt.fill")
                            .contentMode(.center)
                            .tintColor(.systemOrange)
                            .size(width: 24, height: 24)
                        Text("Lazy initialization", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "wrench.and.screwdriver")
                            .contentMode(.center)
                            .tintColor(.systemPurple)
                            .size(width: 24, height: 24)
                        Text("Update properties dynamically", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            VStack(spacing: 20) {
                Text("Basic usage", font: .subtitle)
                VStack(spacing: 4) {
                    Text("Default initialization", font: .bodyBold)
                    Text("Use ViewComponent<ViewType>() to display ViewType inside a UIComponent view hierarchy.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        ViewComponent<UISwitch>().size(width: 62, height: 30)
                    )
                }
                Separator()
                VStack(spacing: 4) {
                    Text("Initialize using generator function", font: .bodyBold)
                    Text("You can also pass in a custom generator function to create the view instance when UIComponent is ready to display it.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        // Exact same behavior as the previous example
                        ViewComponent(generator: UISwitch()).size(width: 62, height: 30)
                    )
                    Text("The generator approach is useful when your view requires custom initialization parameters.", font: .body).textColor(.secondaryLabel).inset(top: 8)
                    #CodeExampleNoInsets(
                        ViewComponent(generator: MyView(color: .red)).size(width: 50, height: 50)
                    )
                    #CodeExampleNoInsets(
                        // You can also use the trailing closure syntax
                        ViewComponent {
                            let button = UIButton(type: .system)
                            button.setTitle("Custom Button", for: .normal)
                            return button
                        }.size(width: 150, height: 50)
                    )
                    VStack(spacing: 4) {
                        Text("UIComponent won't initiate the view until it is about to be displayed. This allows for better performance and memory usage, especially when dealing with large lists of components or frequent component updates.", font: .body).textColor(.systemBlue)
                    }.inset(16).backgroundColor(.systemBlue.withAlphaComponent(0.1)).cornerRadius(16)
                    VStack(spacing: 4) {
                        Text("Because views are initialized at render time, their size won't be available at layout time. Therefore, you should always provide a size for the ViewComponent when using the generator type initializers. Otherwise it will have zero size and won't be visible. For example, the following code doesn't display at all.", font: .body).textColor(.systemRed)
                        #CodeExampleNoInsets(
                            ViewComponent<UISwitch>()
                        )
                    }.inset(16).backgroundColor(.systemRed.withAlphaComponent(0.1)).cornerRadius(16)
                }

                Separator()

                VStack(spacing: 4) {
                    Text("Initialize with existing view", font: .bodyBold)
                    Text("You can also pass in an existing view instance to ViewComponent. This is useful when you have pre-configured views.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        ViewComponent(view: existingSwitch)
                    )
                }

                Separator()

                VStack(spacing: 4) {
                    Text("Using existing view directly", font: .bodyBold)
                    Text("In fact, an easier way would be to use any UIView directly as a Component. UIView conforms to the Component protocol directly and will automatically be wrapped in a ViewComponent internally.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        existingSwitch2
                    )
                }
                VStack(spacing: 6) {
                    Text("Did you notice that when using existing views, size is not required?", font: .bodyBold)
                    Text("This is because the view's intrinsic content size is used for layout. So you can use existing views without specifying size. This is in contrast to generating new views dynamically where size must be specified.", font: .body).textColor(.secondaryLabel)
                }.inset(16).backgroundColor(.secondarySystemBackground).cornerRadius(16)
            }
            
            VStack(spacing: 20) {
                Text("Updating view properties", font: .subtitle)
                VStack(spacing: 4) {
                    Text("Use .update modifier", font: .bodyBold)
                    #CodeExample(
                        ViewComponent<UISwitch>()
                            .update { uiSwitch in
                                uiSwitch.isOn = true
                                uiSwitch.onTintColor = .systemGreen
                            }
                            .size(width: 62, height: 30)
                    )
                }
                Separator()
                VStack(spacing: 4) {
                    Text("Use automatic property setter modifiers (@dynamicMemberLookup)", font: .bodyBold)
                    Text("UIComponent automatically generates property setter modifiers for all properties exist on your UIView class using @dynamicMemberLookup. This allows you to set view properties directly using modifiers named after the properties.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        ViewComponent<UISwitch>()
                            .isOn(true)
                            .onTintColor(.systemRed)
                            .size(width: 62, height: 30)
                    )

                    Text("Built in components are also using this mechanism under the hood. For example, the Image component uses UIImageView internally, so you can use UIImageView's property setter modifiers directly on Image component.", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        Image(systemName: "sparkles") // -> an UIImageView type Component
                            // -> uses UIImageView's tintColor property setter modifier
                            .tintColor(.systemYellow)
                            // -> uses UIImageView's contentMode property setter modifier
                            .contentMode(.center)
                    )
                }
                Separator()
                VStack(spacing: 4) {
                    Text("Use .with modifier", font: .bodyBold)
                    Text("The .with modifier allows you to set properties using key paths. This is useful for setting properties that are not directly available on the class", font: .body).textColor(.secondaryLabel)
                    #CodeExample(
                        ViewComponent<UIView>()
                            .with(\.layer.cornerRadius, 10) // set view.layer.cornerRadius to 10
                            .with(\.backgroundColor, .systemPurple) // same as .backgroundColor(.systemPurple)
                            .size(width: 60, height: 60)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Handling interactions", font: .subtitle)
                VStack(spacing: 6) {
                    Text("It might be temping to add target-action directly using the update modifier, but that can lead to multiple actions being added. Since the update block gets called whenever the component updates.", font: .body).textColor(.systemRed)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .center) {
                            ViewComponent<UISwitch>()
                                .isOn(isEnabled)
                                .update { [weak self] uiSwitch in
                                    uiSwitch.addAction(UIAction { _ in
                                        self?.isEnabled = uiSwitch.isOn
                                    }, for: .valueChanged)
                                }
                                .size(width: 62, height: 30)
                            Text(isEnabled ? "Enabled" : "Disabled", font: .body)
                        }
                    )
                }.inset(16).backgroundColor(.systemRed.withAlphaComponent(0.1)).cornerRadius(16)
                VStack(spacing: 6) {
                    Text("Better way", font: .bodyBold).textColor(.systemGreen)
                    Text("Create a custom view class with a callback variable", font: .body).textColor(.systemGreen)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .center) {
                            ViewComponent<MySwitch>()
                                .isOn(isEnabled)
                                .onToggle { [weak self] isOn in
                                    self?.isEnabled = isOn
                                }
                                .size(width: 62, height: 30)
                            Text(isEnabled ? "Enabled" : "Disabled", font: .body)
                        }
                    )
                    Code(MySwitch.codeRepresentation)
                }.inset(16).backgroundColor(.systemGreen.withAlphaComponent(0.1)).cornerRadius(16)
            }
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

// MARK: - Examples
@GenerateCode
class MyView: UIView {
    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@GenerateCode
class MySwitch: UISwitch {
    var onToggle: ((Bool) -> Void)?

    init() {
        super.init(frame: .zero)
        addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onToggle?(isOn)
        }, for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
