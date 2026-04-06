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
        #expect(animator.timing == .spring(damping: 0.9, initialSpringVelocity: 0))
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
            deleteTransform: deleteTransform,
            timing: .easeInOut,
            duration: 0.25
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, insertTransform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, deleteTransform))
        #expect(animator.timing == .easeInOut)
        #expect(animator.duration == 0.25)
    }

    @Test func durationIsStoredSeparatelyFromTiming() {
        var animator = TransformAnimator(timing: .easeOut, duration: 0.2)

        animator.duration = 0.6

        #expect(animator.timing == .easeOut)
        #expect(animator.duration == 0.6)
    }

    @Test func transformTimingInitializerUsesSameTransformForBothDirections() {
        let transform = CATransform3DMakeTranslation(10, 20, 0)
        let animator = TransformAnimator(
            transform: transform,
            timing: .linear,
            duration: 0.45
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, transform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, transform))
        #expect(animator.timing == .linear)
        #expect(animator.duration == 0.45)
    }

    @Test func timingSupportsBothSpringVariants() {
        let bounceTiming = TransformAnimator.Timing.spring(bounce: 0.2, initialSpringVelocity: 1.5)
        let dampingTiming = TransformAnimator.Timing.spring(damping: 0.85, initialSpringVelocity: 0.5)

        #expect(bounceTiming == .spring(bounce: 0.2, initialSpringVelocity: 1.5))
        #expect(dampingTiming == .spring(damping: 0.85, initialSpringVelocity: 0.5))
    }
}
