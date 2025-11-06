//
//  WaterfallExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

@Observable
class WaterfallExamplesViewModel {
    var imageDatas: [ImageData] = ImageData.sample
    var spacing: CGFloat = 0
    var columns: Int = 2
}

class WaterfallExamplesView: UIView {
    let viewModel = WaterfallExamplesViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("Waterfall Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("Waterfall basics", font: .subtitle)
                Text("Waterfall creates a masonry-style layout with multiple columns. Items are placed in the shortest column, creating a balanced layout for items with varying heights.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Waterfall(columns: 2, spacing: 10) {
                        for i in 1...6 {
                            Text("Item \(i)", font: .body)
                                .inset(15)
                                .backgroundColor(.systemBlue)
                                .size(height: CGFloat(60 + i * 20))
                                .cornerRadius(8)
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Number of columns", font: .subtitle)
                Text("Control how many columns appear in the layout. Default: 2 columns", font: .body).textColor(.secondaryLabel)
                HStack(spacing: 8, alignItems: .center) {
                    ViewComponent<Slider>().value(CGFloat(viewModel.columns - 2) / 8).onValueChanged {
                        viewModel.columns = Int((($0 * 8) + 2).rounded())
                    }.size(width: 200, height: 30)
                    Text("Columns: \(Int(viewModel.columns))", font: .caption)
                }
                #CodeExample(
                    Waterfall(columns: viewModel.columns, spacing: 6) {
                        for i in 1...16 {
                            Text("\(i)", font: .caption)
                                .inset(8)
                                .backgroundColor(.systemPurple)
                                .size(height: CGFloat(40 + (i % 4) * 15))
                                .cornerRadius(4)
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Spacing control", font: .subtitle)
                Text("Adjust the spacing between items in the waterfall.", font: .body).textColor(.secondaryLabel)
                HStack(spacing: 8, alignItems: .center) {
                    ViewComponent<Slider>().value(viewModel.spacing / 50).onValueChanged {
                        viewModel.spacing = ($0 * 50).rounded()
                    }.size(width: 200, height: 30)
                    Text(viewModel.spacing < 1 ? "No spacing" : "Spacing: \(Int(viewModel.spacing))pt", font: .caption)
                }
                #CodeExample(
                    Waterfall(columns: 3, spacing: viewModel.spacing) {
                        for i in 1...9 {
                            Text("\(i)", font: .body)
                                .inset(10)
                                .backgroundColor(.systemTeal)
                                .size(height: CGFloat([60, 80, 70, 90, 65, 85, 75, 95, 70][i-1]))
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Dynamic content", font: .subtitle)
                Text("Waterfall automatically balances items with different heights.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Waterfall(columns: 2, spacing: 10) {
                        Text("Short", font: .body)
                            .inset(15)
                            .backgroundColor(.systemRed)
                            .cornerRadius(8)
                        
                        VStack(spacing: 8) {
                            Text("Tall Item", font: .title)
                            Text("This item has more content and will take up more vertical space.", font: .caption)
                        }
                        .inset(15)
                        .backgroundColor(.systemGreen)
                        .cornerRadius(8)
                        
                        Text("Medium height content here", font: .body)
                            .inset(15)
                            .backgroundColor(.systemBlue)
                            .cornerRadius(8)
                        
                        Text("Another short one", font: .body)
                            .inset(15)
                            .backgroundColor(.systemOrange)
                            .cornerRadius(8)
                        
                        VStack(spacing: 8) {
                            Text("With Image", font: .title)
                            Image(systemName: "star.fill")
                                .tintColor(.yellow)
                            Text("Extra tall item", font: .caption)
                        }
                        .inset(15)
                        .backgroundColor(.systemPurple)
                        .cornerRadius(8)
                        
                        Text("Final", font: .body)
                            .inset(15)
                            .backgroundColor(.systemPink)
                            .cornerRadius(8)
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Photo gallery", font: .subtitle)
                Text("Waterfall is perfect for image galleries with varying aspect ratios.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Waterfall(columns: 3, spacing: 8) {
                        for (index, imageData) in viewModel.imageDatas.enumerated() {
                            AsyncImage(url: imageData.url)
                                .size(width: .fill, height: .aspectPercentage(imageData.size.height / imageData.size.width))
                                .tappableView {
                                    let view = ImageDetailView()
                                    view.imageData = imageData
                                    $0.parentViewController?.present(ViewController(rootView: view), animated: true, completion: nil)
                                }
                                .previewBackgroundColor(.systemBackground.withAlphaComponent(0.7))
                                .previewProvider {
                                    let view = ImageDetailView()
                                    view.imageData = imageData
                                    let vc = ViewController(rootView: view)
                                    vc.preferredContentSize = imageData.size
                                    return vc
                                }
                                .contextMenuProvider { _ in
                                    UIMenu(children: [
                                        UIAction(
                                            title: "Delete",
                                            image: UIImage(systemName: "trash"),
                                            attributes: [.destructive],
                                            handler: { action in
                                                viewModel.imageDatas.remove(at: index)
                                            }
                                        )
                                    ])
                                }
                                .id(imageData.url.absoluteString)
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("HorizontalWaterfall", font: .subtitle)
                Text("HorizontalWaterfall works the same way but arranges items in horizontal rows.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    HorizontalWaterfall(columns: 2, spacing: 10) {
                        for i in 1...8 {
                            Text("Item \(i)", font: .body)
                                .inset(15)
                                .backgroundColor(.systemCyan)
                                .size(width: CGFloat(60 + i * 15))
                                .cornerRadius(8)
                        }
                    }
                    .scrollView()
                    .size(height: 150)
                )
            }
            
            VStack(spacing: 10) {
                Text("Complex items", font: .subtitle)
                Text("Waterfall works with any component, including complex nested layouts.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    Waterfall(columns: 2, spacing: 10) {
                        for i in 1...6 {
                            VStack(spacing: 8, alignItems: .start) {
                                HStack(spacing: 8, alignItems: .center) {
                                    Circle(size: 30)
                                        .backgroundColor(.systemBlue)
                                        .overlay {
                                            Text("\(i)", font: .caption)
                                                .textColor(.white)
                                        }
                                    VStack(spacing: 2, alignItems: .start) {
                                        Text("Item \(i)", font: .title)
                                        Text("Subtitle", font: .caption)
                                            .textColor(.secondaryLabel)
                                    }
                                }
                                
                                if i % 3 == 0 {
                                    Text("This item has additional content that makes it taller than others.", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "heart")
                                        .tintColor(.systemRed)
                                    Text("\(i * 12)", font: .caption)
                                        .textColor(.secondaryLabel)
                                }
                            }
                            .inset(12)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(10)
                        }
                    }
                )
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

class ImageDetailView: UIView {
    var imageData: ImageData? {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    override func updateProperties() {
        super.updateProperties()
        guard let imageData = imageData else {
            return
        }
        componentEngine.component = VStack {
            AsyncImage(url: imageData.url)
                .size(width: .fill, height: .aspectPercentage(imageData.size.height / imageData.size.width))
            VStack(spacing: 10) {
                Text("Image URL: \(imageData.url.absoluteString)", font: .body)
                Text("Image Size: \(Int(imageData.size.width)) x \(Int(imageData.size.height))", font: .body)
            }.inset(20)
        }.ignoreHeightConstraint().scrollView().fill()
    }
}

