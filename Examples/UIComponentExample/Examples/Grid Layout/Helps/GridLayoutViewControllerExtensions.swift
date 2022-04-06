//  Created by y H on 2022/4/6.

import Popover
import UIComponent
import UIKit

extension GridLayoutViewController {
  var addGirdItemFormComponent: Component {
    VStack {
      Join {
        HStack(justifyContent: .spaceBetween, alignItems: .center) {
          Text("Row: \(Int(rowStepper.value))")
          SimpleViewComponent(view: rowStepper)
        }
        HStack(justifyContent: .spaceBetween, alignItems: .center) {
          Text("Column: \(Int(columnStepper.value))")
          SimpleViewComponent(view: columnStepper)
        }
        SimpleViewComponent(view: gridItemContentTextView).size(width: .fill, height: 200)
          .cornerRadius(5)
        HStack(justifyContent: .end, alignItems: .center) {
          Text("Add").textColor(.white).inset(h: 10, v: 5).tappableView { [unowned self] in
            addItem()
            PopoverManager.shared.dismiss()
          }.backgroundColor(.systemBlue)
            .cornerRadius(5)
            .cornerCurve(.continuous)
        }.size(width: .fill)
      } separator: {
        Space(height: 5)
      }
    }.inset(10)
      .size(width: 200)
      .background(UIVisualEffectView(effect: UIBlurEffect(style: .prominent)))
  }

  var gridPreferencesComponent: Component {
    VStack {
      Join {
        HStack(justifyContent: .spaceBetween, alignItems: .center) {
          Text("MainSpacing: \(mainSpacingStepper.value)")
          SimpleViewComponent(view: mainSpacingStepper)
        }
        HStack(justifyContent: .spaceBetween, alignItems: .center) {
          Text("CrossSpacing: \(crossSpacingStepper.value)")
          SimpleViewComponent(view: crossSpacingStepper)
        }
        HStack(justifyContent: .end, alignItems: .center) {
          Text("Apply").textColor(.white).inset(h: 10, v: 5).tappableView { [unowned self] in
            applyGridPreferences()
            PopoverManager.shared.dismiss()
          }.backgroundColor(.systemBlue)
            .cornerRadius(5)
            .cornerCurve(.continuous)
        }.size(width: .fill)
      } separator: {
        Space(height: 5)
      }
    }.inset(10)
      .size(width: 250)
      .background(UIVisualEffectView(effect: UIBlurEffect(style: .prominent)))
  }

  func configureComponent(gridFlow: GridFlow) -> Component {
    GridItemConfigureComponent(gridFlow: gridFlow) { [unowned self] in
      showAddItemPopover(sourceView: $0, flow: gridFlow)
    } tapShuffle: { [unowned self] in
      if gridFlow == .columns {
        horizontalGridPreferencesModel.models.shuffle()
      } else {
        verticalGridPreferencesModel.models.shuffle()
      }
    } tapGridPreferencesPopver: { [unowned self] in
      showGridPreferencesPopver(sourceView: $0, flow: gridFlow)
    }.if(gridFlow == .rows) {
      $0.inset(h: 10, v: 5)
    }.if(gridFlow == .columns) {
      $0.inset(h: 5, v: 10)
    }.background {
      SimpleViewComponent()
        .backgroundColor(gridFlow == .rows ? .secondarySystemGroupedBackground : .tertiarySystemGroupedBackground)
        .cornerRadius(10)
        .cornerCurve(.continuous)
    }
  }
}

func randomText() -> String {
  placeholderText(length: .random(in: 0 ..< 200))
}

func placeholderText(length: Int? = nil) -> String {
  let placeholderText =
    """
    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna
    """

  return placeholderText.prefix(length ?? placeholderText.count) + "!"
}
