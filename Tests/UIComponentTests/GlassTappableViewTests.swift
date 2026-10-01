import Testing
import UIKit
@testable import UIComponent

@Suite("Glass Tappable View Tests")
@MainActor
struct GlassTappableViewTests {
    /// Counts every assignment to a view's `effect`.
    private final class EffectAssignments: NSObject {
        var count = 0

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            count += 1
        }
    }

    @Test func testGlassIsRebuiltOnlyWhenItsTintChangesOrItWasReplaced() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        func render(_ text: String, tintColor: UIColor? = nil) {
            view.componentEngine.component = Text(text).glassTappableView(tintColor: tintColor) {}
            view.componentEngine.reloadData()
        }
        render("A")
        let glass = try #require(view.subviews.first as? GlassTappableView)
        let assignments = EffectAssignments()
        glass.addObserver(assignments, forKeyPath: "effect", options: [], context: nil)
        defer { glass.removeObserver(assignments, forKeyPath: "effect") }

        // Re-rendering the same glass leaves its effect alone.
        render("B")
        #expect(view.subviews.first === glass)
        #expect(assignments.count == 0)

        // A new tint rebuilds the glass once; rendering it again doesn't.
        render("B", tintColor: .red)
        #expect(assignments.count == 1)
        #expect(glass.glassTintColor == .red)
        if #available(iOS 26.0, tvOS 26.0, *) {
            #expect((glass.effect as? UIGlassEffect)?.tintColor == .red)
        }
        render("B", tintColor: .red)
        #expect(assignments.count == 1)

        // An effect set from outside is replaced by the view's own on the next render.
        glass.effect = UIBlurEffect(style: .dark)
        render("B", tintColor: .red)
        #expect(assignments.count == 3)
        render("B", tintColor: .red)
        #expect(assignments.count == 3)
    }
}
