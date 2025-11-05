//
//  PlacementExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class PlacementExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("Placement Examples", font: .title)
            
            // Inset Examples
            VStack(spacing: 12) {
                Text("Inset modifiers", font: .subtitle)
                Text("Inset adds padding around a component. It's the fundamental spacing modifier.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Uniform inset", font: .caption)
                    #CodeExample(
                        Text("Uniform padding", font: .body)
                            .backgroundColor(.systemBlue)
                            .inset(20)
                    )
                    
                    Text("Horizontal and vertical inset", font: .caption)
                    #CodeExample(
                        Text("H: 30, V: 10", font: .body)
                            .backgroundColor(.systemGreen)
                            .inset(h: 30, v: 10)
                    )
                    
                    Text("Individual edge inset", font: .caption)
                    #CodeExample(
                        Text("Top: 20, Rest: 8", font: .body)
                            .backgroundColor(.systemOrange)
                            .inset(top: 30, rest: 8)
                    )
                }
            }
            
            // Offset Examples
            VStack(spacing: 12) {
                Text("Offset modifiers", font: .subtitle)
                Text("Offset moves a component from its original position without affecting layout.", font: .body).textColor(.secondaryLabel)

                #CodeExample(
                    ZStack {
                        Space(width: 20, height: 20).backgroundColor(.systemGray5)
                        Space(width: 20, height: 20).backgroundColor(.systemBlue)
                            .offset(x: 10, y: -10)
                    }.inset(20)
                )
            }
            
            // Overlay Examples
            VStack(spacing: 12) {
                Text("Overlay modifiers", font: .subtitle)
                Text("Overlay places content on top of another component. Simpler than using ZStack. The size of the overlay will match the background component.", font: .body).textColor(.secondaryLabel)

                VStack(spacing: 10) {
                    Text("Simple overlay", font: .caption)
                    #CodeExample(
                        Text("Base content", font: .title)
                            .inset(40)
                            .backgroundColor(.systemGray5)
                            .overlay {
                                Text("Overlay", font: .body)
                                    .textColor(.white)
                                    .backgroundColor(.systemBlue.withAlphaComponent(0.5))
                            }
                    )
                    
                    Text("Loading overlay (from ZStack example)", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Content", font: .title)
                            Text("This content is loading", font: .body)
                        }
                        .inset(30)
                        .overlay {
                            VStack(spacing: 10, justifyContent: .center, alignItems: .center) {
                                Image(systemName: "arrow.clockwise").tintColor(.white)
                                Text("Loading...", font: .body).textColor(.white)
                            }
                            .backgroundColor(.black.withAlphaComponent(0.7))
                        }
                    )
                }
            }
            
            // Background Examples
            VStack(spacing: 12) {
                Text("Background modifiers", font: .subtitle)
                Text("Background places content behind another component. Simpler than using ZStack. The size of the background will match the foreground component.", font: .body).textColor(.secondaryLabel)

                VStack(spacing: 10) {
                    Text("Simple background", font: .caption)
                    #CodeExample(
                        Text("Foreground", font: .body)
                            .inset(20)
                            .background {
                                Text("Background", font: .title).backgroundColor(.systemBlue)
                            }
                    )
                    
                    Text("Gradient background", font: .caption)
                    #CodeExample(
                        Text("Gradient Text", font: .title)
                            .textColor(.white)
                            .inset(30)
                            .background {
                                ViewComponent<GradientView>().colors([.systemPink, .systemPurple])
                                    .cornerRadius(15)
                            }
                    )
                }
            }
            
            // Badge Examples
            VStack(spacing: 12) {
                Text("Badge modifiers", font: .subtitle)
                Text("Badge positions a small overlay relative to content. ", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Notification badge (from ZStack example)", font: .caption)
                    #CodeExample(
                        Image(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                            .tintColor(.label)
                            .badge {
                                Text("3", font: .caption)
                                    .textColor(.white)
                                    .inset(h: 6, v: 2)
                                    .backgroundColor(.systemRed)
                                    .cornerRadius(8)
                            }
                            .inset(10)
                    )
                    
                    Text("Badge positions", font: .caption)
                    #CodeExample(
                        HStack(spacing: 20) {
                            // Top-right (default)
                            Space(width: 50, height: 50)
                                .backgroundColor(.systemBlue)
                                .badge {
                                    Circle(size: 12).backgroundColor(.systemRed)
                                }
                            
                            // Bottom-right
                            Space(width: 50, height: 50)
                                .backgroundColor(.systemGreen)
                                .badge(verticalAlignment: .end) {
                                    Circle(size: 12).backgroundColor(.systemRed)
                                }
                            
                            // Top-left
                            Space(width: 50, height: 50)
                                .backgroundColor(.systemOrange)
                                .badge(horizontalAlignment: .start) {
                                    Circle(size: 12).backgroundColor(.systemRed)
                                }
                        }.inset(10)
                    )
                    
                    Text("Badge with offset", font: .caption)
                    #CodeExample(
                        Image(systemName: "person.circle.fill")
                            .contentMode(.scaleAspectFit)
                            .size(width: 50, height: 50)
                            .tintColor(.systemIndigo)
                            .badge(offset: CGPoint(x: 5, y: -5)) {
                                Image(systemName: "checkmark.circle.fill")
                                    .tintColor(.systemGreen)
                            }
                            .inset(10)
                    )
                }
            }
            
            // Centered Examples
            VStack(spacing: 12) {
                Text("Centered modifier", font: .subtitle)
                Text("Centers content within available space. Uses ZStack with .fill() internally.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Text("Centered", font: .body)
                        .backgroundColor(.systemBlue)
                        .inset(20)
                        .centered()
                        .size(width: 200, height: 200)
                        .backgroundColor(.systemGray6)
                )
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

// Helper gradient view for background example
class GradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    var colors: [UIColor] = [] {
        didSet {
            updateColors()
        }
    }
    func updateColors() {
        (layer as! CAGradientLayer).colors = colors.map { $0.cgColor }
    }
}

struct Circle: ComponentBuilder {
    let size: CGFloat
    
    func build() -> some Component {
        Space(width: size, height: size)
            .roundedCorner()
    }
}
