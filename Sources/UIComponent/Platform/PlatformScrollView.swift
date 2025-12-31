//  Created by Luke Zhao on 12/30/25.

#if os(macOS)
import AppKit

private final class UIComponentFlippedView: NSView {
    override var isFlipped: Bool { true }
}

open class PlatformScrollView: NSScrollView, ComponentDisplayableView {
    public let hostingDocumentView: NSView
    private var boundsObserver: NSObjectProtocol?

    public override init(frame frameRect: NSRect) {
        let documentView = UIComponentFlippedView(frame: .zero)
        documentView.wantsLayer = true
        self.hostingDocumentView = documentView

        super.init(frame: frameRect)

        drawsBackground = false
        hasVerticalScroller = true
        hasHorizontalScroller = false

        self.documentView = documentView

        // Render based on scroll offset (clip view bounds changes).
        contentView.postsBoundsChangedNotifications = true
        boundsObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: contentView,
            queue: nil
        ) { [weak self] _ in
            self?.componentEngine.setNeedsRender()
        }

        // Ensure subviews are mounted into the document view.
        componentEngine.contentView = documentView
    }

    public required init?(coder: NSCoder) {
        let documentView = UIComponentFlippedView(frame: .zero)
        documentView.wantsLayer = true
        self.hostingDocumentView = documentView

        super.init(coder: coder)

        drawsBackground = false
        hasVerticalScroller = true
        hasHorizontalScroller = false

        self.documentView = documentView

        contentView.postsBoundsChangedNotifications = true
        boundsObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: contentView,
            queue: nil
        ) { [weak self] _ in
            self?.componentEngine.setNeedsRender()
        }

        componentEngine.contentView = documentView
    }

    deinit {
        if let boundsObserver {
            NotificationCenter.default.removeObserver(boundsObserver)
        }
    }
}
#endif
