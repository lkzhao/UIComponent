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

    @Test func insetPassesThroughContextExceptIdentityAndReuse() {
        let customKey = RenderNodeContextKey("custom")
        let renderNode = ContextOverrideComponent(
            content: Space(width: 10, height: 10),
            overrideContext: [
                .id: "inner-space",
                .reuseKey: "space",
                customKey: "value"
            ]
        )
        .inset(4)
        .layout(Constraint())

        #expect(renderNode.contextValue(customKey) as? String == "value")
        #expect(renderNode.contextValue(.id) == nil)
        #expect(renderNode.contextValue(.reuseKey) == nil)
    }
}
