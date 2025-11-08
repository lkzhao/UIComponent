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
                        VStack(spacing: 8) {
                            Text("This uses default system font")
                            Text("So does this")
                            Text("And this")
                        }
                    )
                    
                    Text("With font environment", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("This uses bold 18pt font")
                            Text("So does this")
                            Text("And this")
                        }
                        .font(.boldSystemFont(ofSize: 18))
                    )
                    
                    Text("Override environment font", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Uses environment font (bold 18pt)")
                            Text("Uses environment font (bold 18pt)")
                            Text("I override with italic 14pt", font: .italicSystemFont(ofSize: 14))
                        }
                        .font(.boldSystemFont(ofSize: 18))
                    )
                    Text("It also applies to Images (System Symbols only).", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Uses environment font (bold 18pt)")
                            Image(systemName: "alarm")
                            Text("Uses environment font (bold 18pt)")
                            Image(systemName: "alarm")
                            Text("I override with font 14pt", font: .systemFont(ofSize: 14))
                            Image(systemName: "alarm")
                                .font(.systemFont(ofSize: 14))
                        }
                        .font(.boldSystemFont(ofSize: 18))
                    )
                    Text("Usage Tips", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            let defalutConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: .systemPink)
                            Text("Use UIImage.Configuration", font: .systemFont(ofSize: 14))
                            let configuration = UIImage.SymbolConfiguration(scale: .large)
                                .applying(defalutConfiguration)
                            Image(systemName: "alarm", withConfiguration: configuration)
                                .font(nil)
                            Text("Use environment value.", font: .systemFont(ofSize: 14))
                            Image(systemName: "alarm", withConfiguration: defalutConfiguration)
                        }
                        .font(.systemFont(ofSize: 22))
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
                        VStack(spacing: 8) {
                            Text("This text is blue")
                            Text("So is this text")
                            Text("And this one too")
                        }
                        .textColor(.systemBlue)
                    )
                    
                    Text("Combine font and text color", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Large bold red text")
                            Text("Also large bold red text")
                            Text("Small green override", font: .systemFont(ofSize: 12))
                                .textColor(.systemGreen)
                        }
                        .font(.boldSystemFont(ofSize: 20))
                        .textColor(.systemRed)
                    )
                }
            }
            
            // MARK: - ForegroundColor Color Environment
            
            VStack(spacing: 10) {
                Text("Foreground color environment", font: .subtitle)
                Text("Similar to Text color, you can also add a default tint color to Image. However, it's important to note that the priority order of text color in Text is textColor > foregroundColor.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Achieve a consistent style using foregroundColor and font.", font: .caption)
                    #CodeExample(
                        HStack(spacing: 8) {
                            Label("Like", systemImage: "heart")
                                .labelBackground()
                                .foregroundColor(.systemPink)
                            Label("Success", systemImage: "checkmark")
                                .labelBackground()
                                .foregroundColor(.systemGreen)
                            Label("Retry", systemImage: "arrow.trianglehead.clockwise.rotate.90")
                                .labelBackground()
                                .foregroundColor(.systemBlue)
                            Label("Different text colors", systemImage: "scribble")
                                .labelBackground()
                                .foregroundColor(.systemIndigo)
                                .textColor(.systemPurple)
                        }
                        .font(.systemFont(ofSize: 16, weight: .medium))
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
                        VStack(spacing: 12) {
                            Text("Uses outer environment (20pt)")
                            
                            VStack(spacing: 6) {
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
                    )
                    
                    Text("Nested color environments", font: .caption)
                    #CodeExample(
                        VStack(spacing: 12) {
                            Text("Blue text from outer")
                            
                            VStack(spacing: 6) {
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
                        ViewComponent<MySwitch>()
                            .isOn(viewModel.isUserLoggedIn)
                            .onToggle { [weak self] isOn in
                                self?.viewModel.isUserLoggedIn = isOn
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
                            VStack(spacing: 8) {
                                Text("Error Section", font: .title)
                                
                                VStack(spacing: 6) {
                                    HStack(spacing: 8, alignItems: .center) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text("Invalid credentials", font: .bodyBold)
                                    }
                                    Text("The username or password you entered is incorrect. Please try again.")
                                }
                                
                                Text("Try Again", font: .bodyBold)
                                    .inset(h: 16, v: 10)
                                    .textColor(.white)
                                    .backgroundColor(.systemRed)
                                    .cornerRadius(8)
                                    .tappableView { print("Retry") }
                            }
                            .textColor(.systemRed)
                            .view()
                            .tintColor(.systemRed)
                            .backgroundColor(.systemRed.withAlphaComponent(0.1))
                            .cornerRadius(12)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Card with hierarchy", font: .caption)
                        Text("Different font sizes for different levels of hierarchy.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            VStack(spacing: 16) {
                                Text("News Article", font: .title)
                                
                                VStack(spacing: 8) {
                                    Text("Breaking: UIComponent 2.0 Released", font: .title)
                                    Text("The latest version brings new features and improvements")
                                        .textColor(.secondaryLabel)
                                }
                                .font(.systemFont(ofSize: 16))
                                
                                VStack(spacing: 6) {
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
                            .backgroundColor(.systemGray6)
                            .cornerRadius(12)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        // Font size slider
                        HStack(spacing: 12, alignItems: .center) {
                            Text("Font size:", font: .body)
                            ViewComponent<Slider>()
                                .minimumValue(12)
                                .maximumValue(24)
                                .value(viewModel.fontSize)
                                .onValueChanged { [weak self] value in
                                    self?.viewModel.fontSize = value
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
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Use convenience modifiers", font: .bodyBold)
                            Text("Prefer .font() and .textColor() over .environment() for built-in values", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Environment for shared data", font: .bodyBold)
                            Text("Use environment for configuration, themes, and widely-shared context", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Provide sensible defaults", font: .bodyBold)
                            Text("Always define meaningful default values in your environment keys", font: .body)
                                .textColor(.secondaryLabel)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
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
            return VStack(spacing: 8) {
                HStack(spacing: 12, alignItems: .center) {
                    Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                        .tintColor(.systemBlue)
                    
                    VStack(spacing: 4) {
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

