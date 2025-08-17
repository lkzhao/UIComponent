//  Created by Luke Zhao on 2024-12-17.

import UIComponent
import UIKit

// Step 1: Define Theme Data
struct AppTheme {
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let backgroundColor: UIColor
    let textColor: UIColor
    let cornerRadius: CGFloat
    
    static let light = AppTheme(
        primaryColor: .blue,
        secondaryColor: .gray,
        backgroundColor: .white,
        textColor: .black,
        cornerRadius: 8
    )
    
    static let dark = AppTheme(
        primaryColor: .purple,
        secondaryColor: .darkGray,
        backgroundColor: .black,
        textColor: .white,
        cornerRadius: 12
    )
}

// Step 2: Create Environment Key
struct ThemeEnvironmentKey: EnvironmentKey {
    public typealias Value = AppTheme
    public static let defaultValue: AppTheme = .light
}

// Step 3: Extend EnvironmentValues
extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// Step 4: Add Component Modifier
extension Component {
    func theme(_ theme: AppTheme) -> EnvironmentComponent<AppTheme, Self> {
        environment(\.theme, value: theme)
    }
}

// Step 5: Create Themed Components
struct ThemedButton: Component {
    @Environment(\.theme) var theme: AppTheme
    
    let title: String
    let action: () -> Void
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        Text(title)
            .font(.boldSystemFont(ofSize: 16))
            .textColor(.white)
            .textAlignment(.center)
            .backgroundColor(theme.primaryColor)
            .size(width: .fill, height: 50)
            .with(\.layer.cornerRadius, theme.cornerRadius)
            .tappableView { action() }
            .layout(constraint)
    }
}

struct ThemedCard<ChildComponent: Component>: Component {
    @Environment(\.theme) var theme: AppTheme
    
    let content: ChildComponent
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        content
            .inset(16)
            .backgroundColor(theme.backgroundColor)
            .textColor(theme.textColor)
            .with(\.layer.cornerRadius, theme.cornerRadius)
            .with(\.layer.borderWidth, 1)
            .with(\.layer.borderColor, theme.secondaryColor.cgColor)
            .layout(constraint)
    }
}


// Step 6: Custom Switch Component
class Switch: UISwitch {
    var onValueChanged: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc private func valueChanged() {
        onValueChanged?(isOn)
    }
}

// Step 7: Use in Your App
class ThemeSystemViewController: ComponentViewController {
    private var isDarkMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme System"
        view.backgroundColor = .systemBackground
    }
    
    
    override var component: any Component {
        let selectedTheme = isDarkMode ? AppTheme.dark : AppTheme.light
        
        return VStack(spacing: 16) {
            // Theme selector
            HStack {
                Text("Dark Mode")
                    .font(.systemFont(ofSize: 16))
                    .flex()
                
                ViewComponent<Switch>()
                    .size(width: 51, height: 31) // Fixed size for UISwitch
                    .isOn(isDarkMode)
                    .onValueChanged { [weak self] isOn in
                        self?.isDarkMode = isOn
                        self?.reloadComponent()
                    }
            }
            
            // Themed content
            ThemedCard(content: 
                VStack(spacing: 12) {
                    Text("Welcome to UIComponent!")
                        .font(.boldSystemFont(ofSize: 20))
                    
                    Text("This card automatically adapts to the current theme.")
                        .font(.systemFont(ofSize: 16))
                        .textAlignment(.center)
                    
                    ThemedButton(title: "Get Started") {
                        print("Getting started!")
                    }
                }
            )
            
            ThemedCard(content:
                VStack(spacing: 8) {
                    Text("Another Card")
                        .font(.boldSystemFont(ofSize: 18))
                    
                    Text("All components automatically use the theme.")
                        .font(.systemFont(ofSize: 14))
                        .textAlignment(.center)
                }
            )
            
            // Demo of theme values
            ThemedCard(content:
                VStack(spacing: 8) {
                    Text("Current Theme Values:")
                        .font(.boldSystemFont(ofSize: 16))
                    
                    Text("Corner Radius: \(Int(selectedTheme.cornerRadius))px")
                        .font(.systemFont(ofSize: 14))
                    
                    HStack(spacing: 8) {
                        Text("Primary:")
                            .font(.systemFont(ofSize: 14))
                        
                        Text("●")
                            .font(.systemFont(ofSize: 20))
                            .textColor(selectedTheme.primaryColor)
                    }
                }
            )
        }
        .theme(selectedTheme) // Apply theme to entire hierarchy
        .inset(20)
    }
}
