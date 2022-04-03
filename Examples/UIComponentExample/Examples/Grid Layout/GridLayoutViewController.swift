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
    .init(column: 2, row: 1, height: 300),
    .init(column: 2, row: 1, height: nil),
    .init(column: 1, row: 1, height: 200),
    .init(column: 2, row: 1, height: nil),
    .init(column: 3, row: 1, height: 100),
    .init(column: 2, row: 2, height: 250),
    .init(column: 1, row: 1, height: nil),
    .init(column: 1, row: 1, height: 20)
  ] {
    didSet {
      reloadComponent()
    }
  }
  
  override var component: Component {
    Grid(tracks: [.fr(1), .fr(1), .fr(1)], spacing: 0) {
      data.map { model in
        SimpleViewComponent().styleColor(model.color)
          .if(model.height != nil) {
          $0.size(height: model.height!)
        }.gridSpan(model.column, row: model.row)
      }
    }.inset(10)
  }
  
  func placeholderText(length: Int? = nil) -> String {
    let placeholderText =
      """
  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna
  """
    
    return placeholderText.prefix(length ?? placeholderText.count) + "!"
  }
  
}
