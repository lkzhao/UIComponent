import Testing
@testable import UIComponent

@Suite("Transform Animator Tests")
struct TransformAnimatorTests {
    @Test func compatibilityInitializerUsesSameTransformForInsertAndDelete() {
        let transform = CATransform3DMakeScale(0.5, 0.75, 1)

        let animator = TransformAnimator(
            transform: transform,
            duration: 0.7,
            cascade: true,
            layoutSubviews: false,
            showInitialInsertionAnimation: true,
            showInsertionAnimationOnOutOfBoundsItems: true
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, transform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, transform))
        #expect(animator.duration == 0.7)
        #expect(animator.cascade)
        #expect(!animator.layoutSubviews)
        #expect(animator.showInitialInsertionAnimation)
        #expect(animator.showInsertionAnimationOnOutOfBoundsItems)
    }

    @Test func separateTransformsAreStoredIndependently() {
        let insertTransform = CATransform3DMakeTranslation(20, 0, 0)
        let deleteTransform = CATransform3DMakeScale(0.8, 0.8, 1)

        let animator = TransformAnimator(
            insertTransform: insertTransform,
            deleteTransform: deleteTransform
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, insertTransform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, deleteTransform))
    }
}
