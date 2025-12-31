//  Created by Luke Zhao on 11/5/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIComponent

class ZStackExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("ZStack Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("ZStack basics", font: .subtitle)
                Text("ZStack layers its children on top of each other, with the first child at the bottom and the last at the top. Size is determined by the largest child.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    ZStack {
                        Text("Bottom", font: .body).inset(25).backgroundColor(.systemRed)
                        Text("Middle", font: .body).inset(15).backgroundColor(.systemGreen)
                        Text("Top", font: .body).inset(10).backgroundColor(.systemBlue)
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Vertical alignment", font: .subtitle)
                Text("Controls how children align vertically within the ZStack.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("verticalAlignment: .start", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(verticalAlignment: .start) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Small Top", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("verticalAlignment: .center (default)", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(verticalAlignment: .center) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Small Center", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("verticalAlignment: .end", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(verticalAlignment: .end) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Small Bottom", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("verticalAlignment: .stretch", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(verticalAlignment: .stretch) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Small Stretched", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Horizontal alignment", font: .subtitle)
                Text("Controls how children align horizontally within the ZStack.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("horizontalAlignment: .start", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(horizontalAlignment: .start) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Start", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("horizontalAlignment: .center (default)", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(horizontalAlignment: .center) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Center", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("horizontalAlignment: .end", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(horizontalAlignment: .end) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("End", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                    
                    Text("horizontalAlignment: .stretch", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack(horizontalAlignment: .stretch) {
                            Text("Large Background", font: .title).inset(20).backgroundColor(.systemGray5)
                            Text("Stretched", font: .body).inset(10).backgroundColor(.systemBlue)
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Combined alignments", font: .subtitle)
                Text("You can combine vertical and horizontal alignments to position items in different corners.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    ZStack(verticalAlignment: .start, horizontalAlignment: .end) {
                        Text("Background", font: .body).inset(40).backgroundColor(.systemGray5)
                        Text("Top Right", font: .caption).inset(8).backgroundColor(.systemRed)
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Practical examples", font: .subtitle)
                Text("Common use cases for ZStack.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Badge overlay", font: .caption)
                    #CodeExample(
                        ZStack(verticalAlignment: .start, horizontalAlignment: .end) {
                            Image(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)).tintColor(.label)
                            Text("3", font: .caption).textColor(.white).inset(h: 6, v: 2).backgroundColor(.systemRed).cornerRadius(8)
                        }
                    )
                    
                    Text("Loading overlay", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack {
                            VStack(spacing: 10) {
                                Text("Content", font: .title)
                                Text("This is some content that would be loading", font: .body)
                            }.inset(30)
                            
                            VStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)).tintColor(.white)
                                Text("Loading...", font: .body).textColor(.white)
                            }.inset(20).backgroundColor(.black.withAlphaComponent(0.7)).cornerRadius(10)
                        }
                    )
                    
                    Text("Background decoration", font: .caption)
                    #CodeExampleNoInsets(
                        ZStack {
                            Image(systemName: "sparkles", withConfiguration: UIImage.SymbolConfiguration(pointSize: 80)).tintColor(.systemYellow).offset(x: -30, y: -20)
                            Text("Featured", font: .title).inset(20)
                        }
                    )
                }
            }
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}
#endif
