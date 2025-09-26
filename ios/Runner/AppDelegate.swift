import Flutter
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var localNetworkBrowser: NWBrowser?
  private var probeTimer: Timer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    startLocalNetworkProbe()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startLocalNetworkProbe() {
    guard #available(iOS 13.0, *) else { return }

    let parameters = NWParameters()
    parameters.includePeerToPeer = true

    let browser = NWBrowser(
      for: .bonjour(type: "_dartobservatory._tcp", domain: nil),
      using: parameters
    )

    browser.stateUpdateHandler = { state in
      switch state {
      case .ready:
        NSLog("NWBrowser ready - local network permission likely granted")
      case .failed(let error):
        NSLog("NWBrowser failed: \(error.localizedDescription)")
      default:
        break
      }
    }

    browser.browseResultsChangedHandler = { _, _ in
      // No-op: the act of browsing is enough to trigger the dialog.
    }

    localNetworkBrowser = browser
    browser.start(queue: DispatchQueue.global(qos: .background))

    probeTimer?.invalidate()
    probeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
      self?.stopLocalNetworkProbe()
    }
  }

  private func stopLocalNetworkProbe() {
    probeTimer?.invalidate()
    probeTimer = nil

    if #available(iOS 13.0, *) {
      localNetworkBrowser?.cancel()
    }

    localNetworkBrowser = nil
  }
}
