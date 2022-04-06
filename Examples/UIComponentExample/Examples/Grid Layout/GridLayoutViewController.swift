//  Created by y H on 2022/4/2.

import Popover
import UIComponent
import UIKit

struct GridPreferencesModel {
  var tracks: [GridTrack]
  var mainSpacing: CGFloat
  var crossSpacing: CGFloat
  var models: [GridModel] = [.init(column: 2, row: 1, content: randomText()),
                             .init(column: 1, row: 1, content: randomText()),
                             .init(column: 1, row: 2, content: randomText()),
                             .init(column: 1, row: 1, content: randomText()),
                             .init(column: 2, row: 1, content: randomText())]
  static var `default` = GridPreferencesModel(tracks: [.fr(1), .pt(50), .pt(100), .fr(1)], mainSpacing: 10, crossSpacing: 10)
  static var defaultHorizontal = GridPreferencesModel(tracks: [.fr(1), .pt(50), .pt(100), .fr(1)],
                                                      mainSpacing: 10,
                                                      crossSpacing: 10,
                                                      models: [.init(column: 1, row: 2, content: placeholderText(length: 10)),
                                                               .init(column: 1, row: 1, content: placeholderText(length: 20)),
                                                               .init(column: 2, row: 1, content: placeholderText(length: 5)),
                                                               .init(column: 1, row: 1, content: placeholderText(length: 15)),
                                                               .init(column: 1, row: 2, content: placeholderText(length: 8))])
}

struct GridModel {
  let column: Int
  let row: Int
  let content: String
  let color: UIColor = .randomSystemColor()
}

class GridLayoutViewController: ComponentViewController {
  var verticalGridPreferencesModel: GridPreferencesModel = .default {
    didSet {
      reloadComponent()
    }
  }

  var horizontalGridPreferencesModel: GridPreferencesModel = .defaultHorizontal {
    didSet {
      reloadComponent()
    }
  }

  var currentGridFlow: GridFlow = .rows

  lazy var popoverComponentView = ComponentView()
  lazy var columnStepper = UIStepper().then {
    $0.value = 1
    $0.minimumValue = 1
    $0.addTarget(self, action: #selector(updateAdditemComponent), for: .valueChanged)
  }

  lazy var rowStepper = UIStepper().then {
    $0.value = 1
    $0.minimumValue = 1
    $0.addTarget(self, action: #selector(updateAdditemComponent), for: .valueChanged)
  }

  lazy var mainSpacingStepper = UIStepper().then {
    $0.minimumValue = 0
    $0.maximumValue = 100
    $0.addTarget(self, action: #selector(updateGridPreferencesComponent), for: .valueChanged)
  }

  lazy var crossSpacingStepper = UIStepper().then {
    $0.minimumValue = 0
    $0.maximumValue = 100
    $0.addTarget(self, action: #selector(updateGridPreferencesComponent), for: .valueChanged)
  }

  lazy var gridItemContentTextView = UITextView().then {
    $0.backgroundColor = .systemBackground.withAlphaComponent(0.5)
  }

  override var component: Component {
    Grid(tracks: verticalGridPreferencesModel.tracks,
         mainSpacing: verticalGridPreferencesModel.mainSpacing,
         crossSpacing: verticalGridPreferencesModel.crossSpacing) {
      Text("Grid layouts", font: .boldSystemFont(ofSize: 20)).inset(v: 5).gridSpan(column: verticalGridPreferencesModel.tracks.count)
      Grid(tracks: horizontalGridPreferencesModel.tracks,
           flow: .columns,
           mainSpacing: horizontalGridPreferencesModel.mainSpacing,
           crossSpacing: horizontalGridPreferencesModel.crossSpacing) {
        configureComponent(gridFlow: .columns).gridSpan(row: horizontalGridPreferencesModel.tracks.count)

        for data in horizontalGridPreferencesModel.models.enumerated() {
          Text(data.element.content)
            .textColor(.white)
            .inset(10)
            .tappableView { [unowned self] in
              horizontalGridPreferencesModel.models.remove(at: data.offset)
            }
            .cornerRadius(20)
            .cornerCurve(.continuous)
            .backgroundColor(data.element.color.withAlphaComponent(0.5))
            .borderWidth(2)
            .borderColor(data.element.color)
            .gridSpan(column: data.element.column, row: data.element.row)
        }

      }.inset(10)
        .scrollView()
        .with(\.animator, AnimatedReloadAnimator())
        .view()
        .cornerRadius(5)
        .shadowColor(.label)
        .shadowOffset(CGSize(width: 0, height: 3))
        .shadowOpacity(0.1)
        .shadowRadius(8)
        .backgroundColor(.secondarySystemGroupedBackground)
        .inset(bottom: 10)
        .size(height: 400)
        .gridSpan(column: verticalGridPreferencesModel.tracks.count)

      configureComponent(gridFlow: .rows).gridSpan(column: verticalGridPreferencesModel.tracks.count)

      for data in verticalGridPreferencesModel.models.enumerated() {
        Text(data.element.content)
          .textColor(.white)
          .inset(10)
          .tappableView { [unowned self] in
            verticalGridPreferencesModel.models.remove(at: data.offset)
          }.cornerRadius(10)
          .cornerCurve(.continuous)
          .backgroundColor(data.element.color.withAlphaComponent(0.5))
          .borderWidth(2)
          .borderColor(data.element.color)
          .gridSpan(column: data.element.column, row: data.element.row)
      }

    }.inset(10)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    componentView.animator = AnimatedReloadAnimator()
  }

  func showAddItemPopover(sourceView: UIView, flow: GridFlow) {
    currentGridFlow = flow
    rowStepper.maximumValue = flow == .columns ? Double(horizontalGridPreferencesModel.tracks.count) : .infinity
    columnStepper.maximumValue = flow == .columns ? .infinity : Double(verticalGridPreferencesModel.tracks.count)
    rowStepper.value = 1
    columnStepper.value = 1
    gridItemContentTextView.text = randomText()
    popoverComponentView.component = addGirdItemFormComponent
    PopoverManager.shared.popover(popoverComponentView: popoverComponentView,
                                  sourceView: sourceView,
                                  containerView: view)
  }

  func showGridPreferencesPopver(sourceView: UIView, flow: GridFlow) {
    currentGridFlow = flow
    mainSpacingStepper.value = flow == .rows ? verticalGridPreferencesModel.mainSpacing : horizontalGridPreferencesModel.mainSpacing
    crossSpacingStepper.value = flow == .rows ? verticalGridPreferencesModel.crossSpacing : horizontalGridPreferencesModel.crossSpacing
    popoverComponentView.component = gridPreferencesComponent
    PopoverManager.shared.popover(popoverComponentView: popoverComponentView,
                                  sourceView: sourceView,
                                  containerView: view)
  }

  @objc func updateAdditemComponent() {
    popoverComponentView.component = addGirdItemFormComponent
  }

  @objc func updateGridPreferencesComponent() {
    popoverComponentView.component = gridPreferencesComponent
  }

  func addItem() {
    let model = GridModel(column: Int(columnStepper.value),
                          row: Int(rowStepper.value),
                          content: gridItemContentTextView.text)
    if currentGridFlow == .columns {
      horizontalGridPreferencesModel.models.append(model)
    } else {
      verticalGridPreferencesModel.models.append(model)
    }
  }

  func applyGridPreferences() {
    var model = currentGridFlow == .rows ? verticalGridPreferencesModel : horizontalGridPreferencesModel
    model.mainSpacing = mainSpacingStepper.value
    model.crossSpacing = crossSpacingStepper.value
    if currentGridFlow == .rows {
      verticalGridPreferencesModel = model
    } else {
      horizontalGridPreferencesModel = model
    }
  }

  func gridComponent(models: [GridModel], flow: GridFlow) -> ComponentArrayContainer {
    Join {
      for data in models.enumerated() {
        Text(data.element.content)
          .textColor(.white)
          .inset(10)
          .styleColor(data.element.color)
          .tappableView { [unowned self] in
            if flow == .columns {
              horizontalGridPreferencesModel.models.remove(at: data.offset)
            } else {
              verticalGridPreferencesModel.models.remove(at: data.offset)
            }
          }.gridSpan(column: data.element.column, row: data.element.row)
      }
    } separator: {
      Space()
    }
  }
}
