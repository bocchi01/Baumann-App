#if canImport(Flutter) && canImport(UIKit)
import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureFirebaseIfNeeded()
    return super.application(application, willFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureFirebaseIfNeeded()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureFirebaseIfNeeded() {
    guard FirebaseApp.app() == nil else { return }
    FirebaseApp.configure()
  }
}

#elseif canImport(FlutterMacOS)
import FlutterMacOS
import FirebaseCore

@main
class AppDelegate: FlutterAppDelegate {
  override init() {
    super.init()
    configureFirebaseIfNeeded()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    configureFirebaseIfNeeded()
    RegisterGeneratedPlugins(registry: self)
    super.applicationDidFinishLaunching(notification)
  }

  private func configureFirebaseIfNeeded() {
    guard FirebaseApp.app() == nil else { return }
    FirebaseApp.configure()
  }
}
#else
// Fallback to avoid build errors if not importing Flutter (for code completion or previews)
#if canImport(UIKit)
import UIKit
class AppDelegate: UIResponder, UIApplicationDelegate {}
#else
import Foundation
class AppDelegate: NSObject {}
#endif
#endif
