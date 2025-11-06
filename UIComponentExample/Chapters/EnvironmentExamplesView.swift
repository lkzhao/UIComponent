//
//  EnvironmentExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class EnvironmentExamplesView: UIView {
    @Observable
    class EnvironmentViewModel {
        var themeColor: UIColor = .systemBlue
        var fontSize: CGFloat = 16
        var currentUser: User? = User(name: "John Doe", email: "john@example.com", role: "Developer")
        var isUserLoggedIn: Bool = true
    }
    
    let viewModel = EnvironmentViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        
        componentEngine.component = VStack(spacing: 40) {
            Text("Environment Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("What is Environment?", font: .subtitle)
                Text("Environment allows you to pass data down through the component hierarchy without explicitly passing it through every component. It's particularly useful for configuration values, themes, fonts, and other context that many components need access to.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.down.circle")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Implicit data flow through hierarchy", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "checkmark.shield")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Type-safe value access", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "bolt.fill")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Efficient and performant", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "slider.horizontal.3")
                            .tintColor(.systemPurple)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Easy to customize and test", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            // MARK: - Font Environment
            
            VStack(spacing: 10) {
                Text("Font environment", font: .subtitle)
                Text("The font environment allows you to set a default font for text components. Individual Text components can override this with their own font.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Without font environment", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8, alignItems: .start) {
                            Text("This uses default system font")
                            Text("So does this")
                            Text("And this")
                        }.inset(16).backgroundColor(.systemGray6).cornerRadius(8)
                    )
                    
                    Text("With font environment", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8, alignItems: .start) {
                            Text("This uses bold 18pt font")
                            Text("So does this")
                            Text("And this")
                        }
                        .font(.boldSystemFont(ofSize: 18))
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                    
                    Text("Override environment font", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8, alignItems: .start) {
                            Text("Uses environment font (bold 18pt)")
                            Text("Uses environment font (bold 18pt)")
                            Text("I override with italic 14pt", font: .italicSystemFont(ofSize: 14))
                        }
                        .font(.boldSystemFont(ofSize: 18))
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                }
            }
            
            // MARK: - Text Color Environment
            
            VStack(spacing: 10) {
                Text("Text color environment", font: .subtitle)
                Text("Similar to font, you can set a default text color for all text components in a hierarchy.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Set text color environment", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8, alignItems: .start) {
                            Text("This text is blue")
                            Text("So is this text")
                            Text("And this one too")
                        }
                        .textColor(.systemBlue)
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                    
                    Text("Combine font and text color", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8, alignItems: .start) {
                            Text("Large bold red text")
                            Text("Also large bold red text")
                            Text("Small green override", font: .systemFont(ofSize: 12))
                                .textColor(.systemGreen)
                        }
                        .font(.boldSystemFont(ofSize: 20))
                        .textColor(.systemRed)
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                }
            }
            
            // MARK: - Nested Environment Values
            
            VStack(spacing: 10) {
                Text("Nested environment values", font: .subtitle)
                Text("Environment values can be overridden at any level of the hierarchy. Inner environments take precedence over outer ones.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Nested font environments", font: .caption)
                    #CodeExample(
                        VStack(spacing: 12, alignItems: .start) {
                            Text("Uses outer environment (20pt)")
                            
                            VStack(spacing: 6, alignItems: .start) {
                                Text("Uses inner environment (14pt)")
                                Text("Also uses inner (14pt)")
                            }
                            .font(.systemFont(ofSize: 14))
                            .inset(12)
                            .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                            .cornerRadius(8)
                            
                            Text("Back to outer environment (20pt)")
                        }
                        .font(.systemFont(ofSize: 20))
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                    
                    Text("Nested color environments", font: .caption)
                    #CodeExample(
                        VStack(spacing: 12, alignItems: .start) {
                            Text("Blue text from outer")
                            
                            VStack(spacing: 6, alignItems: .start) {
                                Text("Green text from inner")
                                Text("Also green")
                            }
                            .textColor(.systemGreen)
                            .inset(12)
                            .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                            .cornerRadius(8)
                            
                            Text("Blue text again")
                        }
                        .textColor(.systemBlue)
                        .inset(16)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    )
                }
            }
            
            // MARK: - Hosting View Environment
            
            VStack(spacing: 10) {
                Text("Hosting view environment", font: .subtitle)
                Text("The hostingView environment provides access to the UIView that contains your components. This is useful for accessing trait collections, safe areas, or other view properties.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Access hosting view properties", font: .caption)
                    #CodeExample(
                        ThemeAwareComponent()
                            .inset(16)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(8)
                    )
                    
                    Text("Note: The hostingView environment is automatically set by UIComponent when rendering. You don't need to set it manually.", font: .caption).textColor(.secondaryLabel)
                }
            }
            
            // MARK: - TappableView Configuration
            
            VStack(spacing: 10) {
                Text("TappableView configuration environment", font: .subtitle)
                Text("Set default behavior for all tappable components in a hierarchy. This is useful for consistent highlight animations across your UI.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Default behavior (no highlight)", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Tap Me 1", font: .body)
                                .inset(h: 20, v: 12)
                                .backgroundColor(.systemBlue)
                                .textColor(.white)
                                .cornerRadius(8)
                                .tappableView { print("Tapped 1") }
                            
                            Text("Tap Me 2", font: .body)
                                .inset(h: 20, v: 12)
                                .backgroundColor(.systemGreen)
                                .textColor(.white)
                                .cornerRadius(8)
                                .tappableView { print("Tapped 2") }
                        }.inset(16)
                    )
                    
                    Text("With environment config (scale animation)", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Tap Me 1", font: .body)
                                .inset(h: 20, v: 12)
                                .backgroundColor(.systemBlue)
                                .textColor(.white)
                                .cornerRadius(8)
                                .tappableView { print("Tapped 1") }
                            
                            Text("Tap Me 2", font: .body)
                                .inset(h: 20, v: 12)
                                .backgroundColor(.systemGreen)
                                .textColor(.white)
                                .cornerRadius(8)
                                .tappableView { print("Tapped 2") }
                        }
                        .tappableViewConfig(TappableViewConfig(
                            onHighlightChanged: { view, isHighlighted in
                                UIView.animate(withDuration: 0.2) {
                                    view.transform = isHighlighted
                                        ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                                        : .identity
                                }
                            }
                        ))
                        .inset(16)
                    )
                }
            }
            
            // MARK: - Custom Environment Values
            
            VStack(spacing: 10) {
                Text("Creating custom environment values", font: .subtitle)
                Text("You can create your own environment values for app-specific configuration. Here's an example with a User environment value.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    // Toggle for user login state
                    HStack(spacing: 12, alignItems: .center) {
                        Text("User logged in:", font: .body)
                        ViewComponent<UISwitch>()
                            .isOn(viewModel.isUserLoggedIn)
                            .update { [weak self] uiSwitch in
                                uiSwitch.addAction(UIAction { _ in
                                    self?.viewModel.isUserLoggedIn = uiSwitch.isOn
                                }, for: .valueChanged)
                            }
                            .size(width: 62, height: 30)
                    }
                    .inset(h: 16, v: 12)
                    .backgroundColor(.systemGray6)
                    .cornerRadius(12)
                    
                    Text("Component using custom user environment", font: .caption)
                    #CodeExample(
                        UserProfileComponent()
                            .currentUser(viewModel.isUserLoggedIn ? viewModel.currentUser : nil)
                            .inset(16)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(12)
                    )
                    
                    Text("How it works", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        // 1. Define environment key
                        struct CurrentUserEnvironmentKey: EnvironmentKey {
                            static var defaultValue: User? { nil }
                        }
                        
                        // 2. Extend EnvironmentValues
                        extension EnvironmentValues {
                            var currentUser: User? {
                                get { self[CurrentUserEnvironmentKey.self] }
                                set { self[CurrentUserEnvironmentKey.self] = newValue }
                            }
                        }
                        
                        // 3. Add convenience modifier
                        extension Component {
                            func currentUser(_ user: User?) -> EnvironmentComponent<User?, Self> {
                                environment(\\.currentUser, value: user)
                            }
                        }
                        
                        // 4. Use in component
                        struct UserProfileComponent: Component {
                            @Environment(\\.currentUser) var user: User?
                            
                            func layout(_ constraint: Constraint) -> some RenderNode {
                                if let user = user {
                                    return VStack(spacing: 8) {
                                        Text("Welcome, \\(user.name)!")
                                        Text(user.email).textColor(.secondaryLabel)
                                    }.layout(constraint)
                                } else {
                                    return Text("Please log in").layout(constraint)
                                }
                            }
                        }
                        """
                    }
                }
            }
            
            // MARK: - Practical Examples
            
            VStack(spacing: 10) {
                Text("Practical examples", font: .subtitle)
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Themed section", font: .caption)
                        Text("Apply consistent styling to a section of your UI.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            VStack(spacing: 16) {
                                Text("Error Section", font: .title)
                                
                                VStack(spacing: 12, alignItems: .start) {
                                    HStack(spacing: 8, alignItems: .center) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text("Invalid credentials", font: .bodyBold)
                                    }
                                    Text("The username or password you entered is incorrect. Please try again.")
                                }
                                
                                Text("Try Again", font: .bodyBold)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemRed)
                                    .cornerRadius(8)
                                    .tappableView { print("Retry") }
                            }
                            .textColor(.systemRed)
                            .inset(20)
                            .backgroundColor(.systemRed.withAlphaComponent(0.1))
                            .cornerRadius(12)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Card with hierarchy", font: .caption)
                        Text("Different font sizes for different levels of hierarchy.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            VStack(spacing: 16, alignItems: .start) {
                                Text("News Article", font: .title)
                                
                                VStack(spacing: 8, alignItems: .start) {
                                    Text("Breaking: UIComponent 2.0 Released", font: .title)
                                    Text("The latest version brings new features and improvements")
                                        .textColor(.secondaryLabel)
                                }
                                .font(.systemFont(ofSize: 16))
                                
                                VStack(spacing: 6, alignItems: .start) {
                                    Text("What's new:", font: .bodyBold)
                                    Text("• Environment system improvements")
                                    Text("• Better performance")
                                    Text("• More examples")
                                }
                                .font(.systemFont(ofSize: 14))
                                .textColor(.secondaryLabel)
                                
                                Text("Read More →", font: .bodyBold)
                                    .textColor(.systemBlue)
                            }
                            .font(.systemFont(ofSize: 18))
                            .inset(20)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(12)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Form with consistent styling", font: .caption)
                        Text("Apply font and color to an entire form.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            VStack(spacing: 20, alignItems: .stretch) {
                                Text("Contact Form", font: .title)
                                    .textColor(.label)
                                
                                VStack(spacing: 12, alignItems: .stretch) {
                                    VStack(spacing: 6, alignItems: .start) {
                                        Text("Name")
                                        Text("John Doe")
                                            .inset(h: 12, v: 10)
                                            .backgroundColor(.systemBackground)
                                            .cornerRadius(8)
                                            .textColor(.label)
                                    }
                                    
                                    VStack(spacing: 6, alignItems: .start) {
                                        Text("Email")
                                        Text("john@example.com")
                                            .inset(h: 12, v: 10)
                                            .backgroundColor(.systemBackground)
                                            .cornerRadius(8)
                                            .textColor(.label)
                                    }
                                    
                                    VStack(spacing: 6, alignItems: .start) {
                                        Text("Message")
                                        Text("Hello! I'd like to learn more...")
                                            .inset(h: 12, v: 10)
                                            .backgroundColor(.systemBackground)
                                            .cornerRadius(8)
                                            .textColor(.label)
                                    }
                                }
                                
                                Text("Submit", font: .bodyBold)
                                    .textAlignment(.center)
                                    .inset(v: 12)
                                    .backgroundColor(.systemBlue)
                                    .textColor(.white)
                                    .cornerRadius(8)
                                    .tappableView { print("Submit") }
                            }
                            .font(.systemFont(ofSize: 14))
                            .textColor(.secondaryLabel)
                            .inset(20)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(12)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        // TODO: 
//                        Text("Dynamic theme switching", font: .caption)
//                        Text("Change environment values and see components update automatically.", font: .caption).textColor(.secondaryLabel)
//                        
//                        // Theme color picker
//                        HStack(spacing: 8) {
//                            Text("Theme color:", font: .body)
//                            ForEach([UIColor.systemBlue, UIColor.systemGreen, UIColor.systemOrange, UIColor.systemPurple, UIColor.systemPink]) { color in
//                                Space(width: 40, height: 40)
//                                    .backgroundColor(color)
//                                    .cornerRadius(8)
//                                    .overlay {
//                                        if viewModel.themeColor == color {
//                                            Image(systemName: "checkmark")
//                                                .tintColor(.white)
//                                        }
//                                    }
//                                    .tappableView {
//                                        viewModel.themeColor = color
//                                    }
//                            }
//                        }
//                        .inset(h: 16, v: 12)
//                        .backgroundColor(.systemGray6)
//                        .cornerRadius(12)
                        
                        // Font size slider
                        HStack(spacing: 12, alignItems: .center) {
                            Text("Font size:", font: .body)
                            ViewComponent<UISlider>()
                                .minimumValue(12)
                                .maximumValue(24)
                                .value(Float(viewModel.fontSize))
                                .update { [weak self] slider in
                                    slider.addAction(UIAction { _ in
                                        self?.viewModel.fontSize = CGFloat(slider.value)
                                    }, for: .valueChanged)
                                }
                                .size(width: 150, height: 30)
                                .flex()
                            Text("\(Int(viewModel.fontSize))pt", font: .body)
                                .size(width: 40)
                                .textAlignment(.right)
                        }
                        .inset(h: 16, v: 12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(12)
                        
                        #CodeExample(
                            VStack(spacing: 16, alignItems: .center) {
                                Text("Themed Content", font: .title)
                                
                                VStack(spacing: 12) {
                                    Text("This text adapts to the theme color")
                                    Text("Font size also updates dynamically")
                                    Text("All children inherit the environment")
                                }
                                
                                HStack(spacing: 10) {
                                    Text("Button 1")
                                        .inset(h: 16, v: 10)
                                        .backgroundColor(viewModel.themeColor)
                                        .textColor(.white)
                                        .cornerRadius(8)
                                        .tappableView { print("Button 1") }
                                    
                                    Text("Button 2")
                                        .inset(h: 16, v: 10)
                                        .backgroundColor(viewModel.themeColor)
                                        .textColor(.white)
                                        .cornerRadius(8)
                                        .tappableView { print("Button 2") }
                                }
                            }
                            .font(.systemFont(ofSize: viewModel.fontSize))
                            .textColor(viewModel.themeColor)
                            .inset(20)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(12)
                        )
                    }
                }
            }
            
            // MARK: - Best Practices
            
            VStack(spacing: 10) {
                Text("Best practices", font: .subtitle)
                VStack(spacing: 12) {
                    HStack(spacing: 10, alignItems: .start) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("Use convenience modifiers", font: .bodyBold)
                            Text("Prefer .font() and .textColor() over .environment() for built-in values", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10, alignItems: .start) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("Environment for shared data", font: .bodyBold)
                            Text("Use environment for configuration, themes, and widely-shared context", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10, alignItems: .start) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("Provide sensible defaults", font: .bodyBold)
                            Text("Always define meaningful default values in your environment keys", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10, alignItems: .start) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("Don't overuse", font: .bodyBold)
                            Text("For data used by one or two components, consider passing it directly", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                }
                .inset(16)
                .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                .cornerRadius(12)
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

// MARK: - Supporting Types

struct User {
    let name: String
    let email: String
    let role: String
}

// MARK: - Custom Environment Key

struct CurrentUserEnvironmentKey: EnvironmentKey {
    public typealias Value = User?
    public static let defaultValue: User? = nil
}

extension EnvironmentValues {
    var currentUser: User? {
        get { self[CurrentUserEnvironmentKey.self] }
        set { self[CurrentUserEnvironmentKey.self] = newValue }
    }
}

extension Component {
    func currentUser(_ user: User?) -> EnvironmentComponent<User?, Self> {
        environment(\.currentUser, value: user)
    }
}

// MARK: - Example Components

struct UserProfileComponent: Component {
    @Environment(\.currentUser) var user: User?
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        if let user = user {
            return VStack(spacing: 8, alignItems: .start) {
                HStack(spacing: 12, alignItems: .center) {
                    Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                        .tintColor(.systemBlue)
                    
                    VStack(spacing: 4, alignItems: .start) {
                        Text("Welcome, \(user.name)!", font: .bodyBold)
                        Text(user.email, font: .body)
                            .textColor(.secondaryLabel)
                        Text("Role: \(user.role)", font: .caption)
                            .textColor(.secondaryLabel)
                    }
                }
            }.layout(constraint)
        } else {
            return VStack(spacing: 12, alignItems: .center) {
                Image(systemName: "person.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                    .tintColor(.secondaryLabel)
                Text("Please log in", font: .body)
                    .textColor(.secondaryLabel)
                Text("Sign In", font: .bodyBold)
                    .inset(h: 20, v: 10)
                    .backgroundColor(.systemBlue)
                    .textColor(.white)
                    .cornerRadius(8)
                    .tappableView { print("Sign in tapped") }
            }.layout(constraint)
        }
    }
}

struct ThemeAwareComponent: Component {
    @Environment(\.hostingView) var hostingView: UIView?
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        let isDarkMode = hostingView?.traitCollection.userInterfaceStyle == .dark
        
        return VStack(spacing: 12, alignItems: .center) {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
                .tintColor(isDarkMode ? .systemIndigo : .systemYellow)
            
            VStack(spacing: 4) {
                Text("Current theme:", font: .caption)
                    .textColor(.secondaryLabel)
                Text(isDarkMode ? "Dark Mode" : "Light Mode", font: .bodyBold)
            }
            
            Text("This component reads the hosting view's trait collection to determine the current appearance.", font: .caption)
                .textAlignment(.center)
                .textColor(.secondaryLabel)
        }.layout(constraint)
    }
}

