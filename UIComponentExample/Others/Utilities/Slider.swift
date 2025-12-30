//  Created by Luke Zhao on 11/5/25.

class Slider: UIView {
    let slider = UISlider()
    var onValueChanged: ((CGFloat) -> Void)?
    var minimumValue: CGFloat {
        get { CGFloat(slider.minimumValue) }
        set { slider.minimumValue = Float(newValue) }
    }
    var maximumValue: CGFloat {
        get { CGFloat(slider.maximumValue) }
        set { slider.maximumValue = Float(newValue) }
    }
    var value: CGFloat = 0.0 {
        didSet {
            guard !slider.isTracking else { return }
            slider.value = Float(value)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        componentEngine.component = slider.fill()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func valueChanged() {
        value = CGFloat(slider.value)
        onValueChanged?(CGFloat(value))
    }
}
