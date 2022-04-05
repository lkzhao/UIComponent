//  Created by y H on 2022/4/2.

import UIComponent
import UIKit

class GridLayoutViewController: ComponentViewController {
  struct Model {
    let column: Int
    let row: Int
    let height: CGFloat?
    let color: UIColor = .randomSystemColor()
  }
  
  var data: [Model] = [
    .init(column: 1, row: 2, height: nil),
    .init(column: 1, row: 2, height: nil),
    .init(column: 1, row: 4, height: nil),
    .init(column: 2, row: 2, height: nil),
    .init(column: 1, row: 1, height: nil),
    .init(column: 1, row: 1, height: nil),
    .init(column: 1, row: 2, height: nil),
    .init(column: 1, row: 1, height: nil),
    .init(column: 1, row: 1, height: nil),
    .init(column: 1, row: 1, height: nil),
  ] {
    didSet {
      reloadComponent()
    }
  }
  
  override var component: Component {
    
    Grid(tracks: 3, spacing: 10) {
      
      Grid(tracks: [.fr(1), .fr(1)], flow: .columns, spacing: 5) {
        SimpleViewComponent().styleColor(.green)
        SimpleViewComponent().styleColor(.red).gridSpan(column: 2, row: 1)
        SimpleViewComponent().styleColor(.blue)
        SimpleViewComponent().styleColor(.systemPink).gridSpan(column: 2, row: 1)
      }.inset(5)
        .scrollView()
        .view()
        .cornerRadius(5)
        .shadowColor(.label)
        .shadowOffset(CGSize(width: 0, height: 3))
        .shadowOpacity(0.1)
        .shadowRadius(8)
        .backgroundColor(.secondarySystemGroupedBackground)
        .inset(bottom: 10)
        .gridSpan(column: 3, row: 1)
      
      Text("test").tappableView { [unowned self] in
        data = data.shuffled()
      }.gridSpan(column: 1, row: 1)
      
      data.enumerated().map { model in
        SimpleViewComponent().styleColor(model.element.color)
          .if(model.element.height != nil) {
            $0.size(height: model.element.height!)
          }.overlay {
            Text("index: \(model.offset)").centered()
          }.gridSpan(column: model.element.column, row: model.element.row)
      }
    }.inset(10)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    componentView.animator = AnimatedReloadAnimator()
  }
}
