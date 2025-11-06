//
//  FlowExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

@Observable
class FlowExamplesViewModel {
    var lineSpacing: CGFloat = 8
    var interitemSpacing: CGFloat = 8
    var justifyContent: MainAxisAlignment = .start
    var alignItems: CrossAxisAlignment = .start
}

class FlowExamplesView: UIView {
    let viewModel = FlowExamplesViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("Flow Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("Flow basics", font: .subtitle)
                Text("Flow (FlexRow) creates a horizontal wrapping layout similar to UICollectionViewFlowLayout. Items flow from left to right, wrapping to the next line when space runs out.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Flow(spacing: 8) {
                        for i in 1...8 {
                            Text("Item \(i)", font: .body)
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemBlue)
                                .cornerRadius(6)
                        }
                    }.size(width: 250)
                )
            }
            
            VStack(spacing: 10) {
                Text("Line and interitem spacing", font: .subtitle)
                Text("Control spacing between lines (vertical) and between items within a line (horizontal) independently.", font: .body).textColor(.secondaryLabel)
                HStack(spacing: 8, alignItems: .center) {
                    ViewComponent<Slider>().value(viewModel.lineSpacing / 30).onValueChanged {
                        viewModel.lineSpacing = ($0 * 30).rounded()
                    }.size(width: 150, height: 30)
                    Text("Line: \(Int(viewModel.lineSpacing))pt", font: .caption)
                }
                HStack(spacing: 8, alignItems: .center) {
                    ViewComponent<Slider>().value(viewModel.interitemSpacing / 30).onValueChanged {
                        viewModel.interitemSpacing = ($0 * 30).rounded()
                    }.size(width: 150, height: 30)
                    Text("Item: \(Int(viewModel.interitemSpacing))pt", font: .caption)
                }
                #CodeExample(
                    Flow(lineSpacing: viewModel.lineSpacing, interitemSpacing: viewModel.interitemSpacing) {
                        for i in 1...12 {
                            Text("Item \(i)", font: .body)
                                .inset(10)
                                .backgroundColor(.systemPurple)
                                .cornerRadius(4)
                        }
                    }.size(width: 250)
                )
            }
            
            VStack(spacing: 10) {
                Text("Justify content (horizontal alignment)", font: .subtitle)
                Text("Controls how items are distributed horizontally within each line.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("justifyContent: .start (default)", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .start) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                    
                    Text("justifyContent: .center", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .center) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemGreen)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                    
                    Text("justifyContent: .end", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .end) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemOrange)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                    
                    Text("justifyContent: .spaceBetween", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .spaceBetween) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemRed)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                    
                    Text("justifyContent: .spaceAround", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .spaceAround) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemPurple)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                    
                    Text("justifyContent: .spaceEvenly", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, justifyContent: .spaceEvenly) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemTeal)
                                    .cornerRadius(6)
                            }
                        }.size(width: 300)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Align items (vertical alignment within each line)", font: .subtitle)
                Text("Controls how items align vertically within each line when items have different heights.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("alignItems: .start (default)", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemBlue).cornerRadius(4)
                            Text("Large", font: .title).inset(12).backgroundColor(.systemBlue).cornerRadius(4)
                            Text("Medium", font: .subtitle).inset(10).backgroundColor(.systemBlue).cornerRadius(4)
                            Text("Tiny", font: .caption).inset(6).backgroundColor(.systemBlue).cornerRadius(4)
                        }.size(width: 300)
                    )
                    
                    Text("alignItems: .center", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignItems: .center) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemGreen).cornerRadius(4)
                            Text("Large", font: .title).inset(12).backgroundColor(.systemGreen).cornerRadius(4)
                            Text("Medium", font: .subtitle).inset(10).backgroundColor(.systemGreen).cornerRadius(4)
                            Text("Tiny", font: .caption).inset(6).backgroundColor(.systemGreen).cornerRadius(4)
                        }.size(width: 300)
                    )
                    
                    Text("alignItems: .end", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignItems: .end) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemOrange).cornerRadius(4)
                            Text("Large", font: .title).inset(12).backgroundColor(.systemOrange).cornerRadius(4)
                            Text("Medium", font: .subtitle).inset(10).backgroundColor(.systemOrange).cornerRadius(4)
                            Text("Tiny", font: .caption).inset(6).backgroundColor(.systemOrange).cornerRadius(4)
                        }.size(width: 300)
                    )
                    
                    Text("alignItems: .stretch", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignItems: .stretch) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemPurple).cornerRadius(4)
                            Text("Large", font: .title).inset(12).backgroundColor(.systemPurple).cornerRadius(4)
                            Text("Medium", font: .subtitle).inset(10).backgroundColor(.systemPurple).cornerRadius(4)
                            Text("Tiny", font: .caption).inset(6).backgroundColor(.systemPurple).cornerRadius(4)
                        }.size(width: 300)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Align content (multi-line alignment)", font: .subtitle)
                Text("Controls how multiple lines are distributed vertically when there's extra space in the container. Only visible when the container has a fixed height.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("alignContent: .start (default)", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .start) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                    
                    Text("alignContent: .center", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .center) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemGreen)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                    
                    Text("alignContent: .end", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .end) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemOrange)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                    
                    Text("alignContent: .spaceBetween", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .spaceBetween) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemRed)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                    
                    Text("alignContent: .spaceAround", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .spaceAround) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemPurple)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                    
                    Text("alignContent: .spaceEvenly", font: .caption)
                    #CodeExample(
                        Flow(spacing: 8, alignContent: .spaceEvenly) {
                            for i in 1...5 {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 12, v: 8)
                                    .backgroundColor(.systemTeal)
                                    .cornerRadius(6)
                            }
                        }
                        .inset(10)
                        .size(width: 300, height: 200)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Align self", font: .subtitle)
                Text("Individual items can override the parent's alignItems using the alignSelf modifier.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Flow(spacing: 8) {
                        Text("Default", font: .body)
                            .inset(12)
                            .backgroundColor(.systemBlue)
                            .cornerRadius(4)

                        Text("Center", font: .body)
                            .inset(12)
                            .backgroundColor(.systemGreen)
                            .cornerRadius(4)
                            .alignSelf(.center)

                        Text("End", font: .body)
                            .inset(12)
                            .backgroundColor(.systemOrange)
                            .cornerRadius(4)
                            .alignSelf(.end)

                        Text("Stretch", font: .title)
                            .inset(20)
                            .backgroundColor(.systemPurple)
                            .cornerRadius(4)
                            .alignSelf(.stretch)
                    }.inset(10)
                )
            }

            VStack(spacing: 10) {
                Text("FlexColumn", font: .subtitle)
                Text("FlexColumn works similarly but arranges items vertically and wraps to new columns.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    FlexColumn(spacing: 8) {
                        for i in 1...12 {
                            Text("Item \(i)", font: .body)
                                .inset(h: CGFloat(12 + i * 5), v: 8)
                                .backgroundColor(.systemCyan)
                                .cornerRadius(6)
                        }
                    }
                    .inset(10)
                    .scrollView()
                    .size(width: 300, height: 100)
                )
            }

            VStack(spacing: 10) {
                Text("Practical example: Color palette", font: .subtitle)
                Text("Display a palette of colors with equal-sized swatches that wrap.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Flow(spacing: 10) {
                        for color in [UIColor.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemMint, .systemTeal, .systemCyan, .systemBlue, .systemIndigo, .systemPurple, .systemPink, .systemBrown] {
                            Space(width: 50, height: 50)
                                .backgroundColor(color)
                                .cornerRadius(10)
                        }
                    }.size(width: 300)
                )
            }

            VStack(spacing: 10) {
                Text("Practical example: Tag cloud", font: .subtitle)
                Text("Flow is perfect for tag clouds, where tags have varying widths and should wrap naturally.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Flow(spacing: 10) {
                        for tag in ["Swift", "UIKit", "iOS Development", "Xcode", "SwiftUI", "Combine", "Core Data", "Animations", "Networking", "Design Patterns", "MVVM", "Testing"] {
                            HStack(spacing: 6, alignItems: .center) {
                                Image(systemName: "tag.fill")
                                    .contentMode(.scaleAspectFit)
                                    .size(width: 12, height: 12)
                                    .tintColor(.systemBlue)
                                Text(tag, font: .body)
                            }
                            .inset(h: 12, v: 8)
                            .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                            .cornerRadius(16)
                        }
                    }.inset(10)
                )
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Filter chips", font: .subtitle)
                Text("Flow works great for filter chips with selection states.", font: .body).textColor(.secondaryLabel)
                ViewComponent<FilterChipsExampleView>()
                    .size(width: 360, height: 130)
                Code(FilterChipsExampleView.codeRepresentation)
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

@GenerateCode
class FilterChipsExampleView: UIView {
    @Observable
    class FilterChipsViewModel {
        var selectedFilters: Set<String> = []
    }

    let viewModel = FilterChipsViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        let filters = ["All", "Photos", "Videos", "Documents", "Music", "Recent", "Favorites", "Shared"]
        componentEngine.component = Flow(spacing: 10) {
            for filter in filters {
                let isSelected = viewModel.selectedFilters.contains(filter)
                HStack(spacing: 6, alignItems: .center) {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .tintColor(.white)
                    }
                    Text(filter, font: .body).textColor(isSelected ? .white : .label)
                }
                .inset(h: 14, v: 8)
                .tappableView {
                    if viewModel.selectedFilters.contains(filter) {
                        viewModel.selectedFilters.remove(filter)
                    } else {
                        viewModel.selectedFilters.insert(filter)
                    }
                }
                .backgroundColor(isSelected ? .systemBlue : .systemGray5)
                .cornerRadius(18)
            }
        }
    }
}

