import Testing
@testable import UIComponent

@Suite("Render Node Animation Tests")
struct RenderNodeAnimationTests {
    @Test func animatorWrapperPassesThroughNonAnimatorContextValues() {
        let renderNode = Space(width: 10, height: 10)
            .id("animated-space")
            .reuseKey("space")
            .animateUpdate { _, view, frame in
                view.frame = frame
            }
            .layout(Constraint())

        #expect(renderNode.id == "animated-space")
        #expect(renderNode.reuseKey == "space")
        #expect(renderNode.animator != nil)
    }
}
