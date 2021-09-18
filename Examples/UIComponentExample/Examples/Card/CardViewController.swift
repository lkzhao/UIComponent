//  Created by Luke Zhao on 2018-12-13.

import UIComponent
import UIKit

private class CardView: UIView {
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 22)
    return label
  }()
  let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  var onTap: (() -> Void)?
  var data: CardData? {
    didSet {
      titleLabel.text = data?.title
      subtitleLabel.text = data?.subtitle
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .systemBackground
    layer.cornerRadius = 8
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.2
    layer.shadowOffset = CGSize(width: 0, height: 2)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  @objc func didTap() {
    onTap?()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = CGRect(x: 20, y: 12, width: bounds.width - 40, height: 30)
    subtitleLabel.frame = CGRect(x: 20, y: 40, width: bounds.width - 40, height: 30)
  }
}

private struct CardViewComponent: ViewComponent {
  let data: CardData
  let onTap: () -> Void
  func layout(_ constraint: Constraint) -> CardViewRenderNode {
    CardViewRenderNode(data: data, onTap: onTap, size: CGSize(width: constraint.maxSize.width, height: 80))
  }
}

private struct CardViewRenderNode: ViewRenderNode {
  let data: CardData
  let onTap: () -> Void
  var id: String? {
    data.id
  }
  let size: CGSize
  func updateView(_ view: CardView) {
    view.data = data
    view.onTap = onTap
  }
}

class CardViewController: ComponentViewController {
  var newCardIndex = CardData.testCards.count + 1
  var cards: [CardData] = CardData.testCards {
    didSet {
      reloadComponent()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }

  override var component: Component {
    VStack(spacing: 8) {
      for (index, card) in cards.enumerated() {
        CardViewComponent(data: card) { [unowned self] in
          print("Tapped \(card.title)")
          self.cards.remove(at: index)
        }
      }
      AddCardButton { [unowned self] in
        self.cards.append(
          CardData(
            title: "Item \(self.newCardIndex)",
            subtitle: "Description \(self.newCardIndex)"
          )
        )
        self.newCardIndex += 1
      }
    }
    .inset(20)
  }
}
