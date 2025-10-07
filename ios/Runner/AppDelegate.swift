#if canImport(Flutter) && canImport(UIKit)
import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var tabController: NativeGlassTabBarController?

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
    
    // Setup native glass tab bar overlay
    setupNativeTabBar()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureFirebaseIfNeeded() {
    guard FirebaseApp.app() == nil else { return }
    FirebaseApp.configure()
  }
  
  // MARK: - Native Tab Bar Setup
  
  private func setupNativeTabBar() {
    guard let window = window,
          let flutterViewController = window.rootViewController as? FlutterViewController else {
      return
    }

    // Crea controller nativo
    let controller = NativeGlassTabBarController()
    tabController = controller

    // Container per embedding
    let container = UIViewController()
    container.view.backgroundColor = .clear

    // Embedding: Flutter come child sotto, tab bar sopra
    container.addChild(flutterViewController)
    container.view.addSubview(flutterViewController.view)
    flutterViewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      flutterViewController.view.topAnchor.constraint(equalTo: container.view.topAnchor),
      flutterViewController.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
      flutterViewController.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
      flutterViewController.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor)
    ])
    flutterViewController.didMove(toParent: container)

    // Aggiungi tab controller sopra
    container.addChild(controller)
    container.view.addSubview(controller.view)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    controller.view.backgroundColor = .clear
    NSLayoutConstraint.activate([
      controller.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
      controller.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
      controller.view.topAnchor.constraint(equalTo: container.view.topAnchor),
      controller.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor)
    ])
    controller.didMove(toParent: container)

    window.rootViewController = container
    window.makeKeyAndVisible()

    // Setup Method Channel
    let channel = FlutterMethodChannel(
      name: "glass_tab_bar",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    controller.attachChannel(channel)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      
      switch call.method {
      case "setTabs":
        if let args = call.arguments as? [String: Any],
           let tabs = args["tabs"] as? [[String: Any]] {
          self.tabController?.setTabs(tabs)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing tabs", details: nil))
        }
        
      case "setSelectedIndex":
        if let args = call.arguments as? [String: Any],
           let index = args["index"] as? Int {
          self.tabController?.setSelectedIndex(index)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing index", details: nil))
        }
        
      case "show":
        if let args = call.arguments as? [String: Any],
           let shown = args["shown"] as? Bool {
          self.tabController?.show(shown)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing shown", details: nil))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
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
