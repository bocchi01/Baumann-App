#if canImport(UIKit)
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override init() {
    super.init()
    configureFirebaseIfNeeded()
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
import FirebaseCore // <-- Aggiunto l'import mancante

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
#endif
