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
        #expect(animator.insertTiming == .spring(duration: 0.7, damping: 0.9, initialSpringVelocity: 0))
        #expect(animator.updateTiming == .spring(duration: 0.7, damping: 0.9, initialSpringVelocity: 0))
        #expect(animator.deleteTiming == .spring(duration: 0.7, damping: 0.9, initialSpringVelocity: 0))
        #expect(animator.timing == .spring(duration: 0.7, damping: 0.9, initialSpringVelocity: 0))
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
            timing: .easeInOut(duration: 0.25)
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, insertTransform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, deleteTransform))
        #expect(animator.timing == .easeInOut(duration: 0.25))
        #expect(animator.duration == 0.25)
    }

    @Test func durationSetterUpdatesAllTimings() {
        var animator = TransformAnimator(timing: .easeOut(duration: 0.2))

        animator.duration = 0.6

        #expect(animator.insertTiming == .easeOut(duration: 0.6))
        #expect(animator.updateTiming == .easeOut(duration: 0.6))
        #expect(animator.deleteTiming == .easeOut(duration: 0.6))
        #expect(animator.duration == 0.6)
    }

    @Test func transformTimingInitializerUsesSameTransformForBothDirections() {
        let transform = CATransform3DMakeTranslation(10, 20, 0)
        let animator = TransformAnimator(
            transform: transform,
            timing: .linear(duration: 0.45)
        )

        #expect(CATransform3DEqualToTransform(animator.insertTransform, transform))
        #expect(CATransform3DEqualToTransform(animator.deleteTransform, transform))
        #expect(animator.timing == .linear(duration: 0.45))
        #expect(animator.duration == 0.45)
    }

    @Test func separateTimingsAreStoredIndependently() {
        let animator = TransformAnimator(
            insertTiming: .easeIn(duration: 0.2),
            updateTiming: .linear(duration: 0.4),
            deleteTiming: .spring(duration: 0.6, damping: 0.8, initialSpringVelocity: 0.3)
        )

        #expect(animator.insertTiming == .easeIn(duration: 0.2))
        #expect(animator.updateTiming == .linear(duration: 0.4))
        #expect(animator.deleteTiming == .spring(duration: 0.6, damping: 0.8, initialSpringVelocity: 0.3))
    }

    @Test func timingSupportsBothSpringVariants() {
        let bounceTiming = TransformAnimator.Timing.spring(duration: 0.4, bounce: 0.2, initialSpringVelocity: 1.5)
        let dampingTiming = TransformAnimator.Timing.spring(duration: 0.3, damping: 0.85, initialSpringVelocity: 0.5)

        #expect(bounceTiming.duration == 0.4)
        #expect(dampingTiming.duration == 0.3)
        #expect(bounceTiming == .spring(duration: 0.4, bounce: 0.2, initialSpringVelocity: 1.5))
        #expect(dampingTiming == .spring(duration: 0.3, damping: 0.85, initialSpringVelocity: 0.5))
    }
}
