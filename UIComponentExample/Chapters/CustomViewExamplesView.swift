//  Created by Luke Zhao on 11/4/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
@GenerateCode
class MyCustomView: UIView {
    var name: String = ""
}

class CustomViewExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack {
            Text("Custom View", font: .title)
            ViewComponent<MyCustomView>().size(width: 200, height: 50)
            Code(MyCustomView.codeRepresentation)
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}
#endif
