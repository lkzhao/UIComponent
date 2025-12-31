//  Created by Luke Zhao on 11/4/25.

@_exported import CodeExample
@_exported import UIComponent

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
@_exported import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

#elseif os(macOS)
import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var window: NSWindow?

  func applicationDidFinishLaunching(_ notification: Notification) {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 1000, height: 720),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "UIComponentExample"
    window.center()

    let hostingView = NSView()
    hostingView.componentEngine.component = VStack(spacing: 12, justifyContent: .center, alignItems: .center) {
      Text("UIComponent Example", font: .boldSystemFont(ofSize: 24))
      Text("macOS build is a minimal shell (examples are iOS-first for now).", font: .systemFont(ofSize: 14))
        .textColor(.systemGray)
      Space(width: 200, height: 200).backgroundColor(.blue)
    }
    .inset(24)
    .fill()

    window.contentView = hostingView
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    self.window = window
  }
}

class UIComponentExampleApplication: NSApplication {
  let strongDelegate = AppDelegate()

  override init() {
    super.init()
    self.delegate = strongDelegate
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
#endif
