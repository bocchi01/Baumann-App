// NativeGlassTabBarController.swift
// Baumann Posture App - Native iOS 26 Glass Tab Bar
import UIKit
import Flutter

/// View custom che lascia passare i tap tranne nella zona della tabBar
private final class PassthroughView: UIView {
    weak var targetView: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let target = targetView else {
            return nil
        }
        
        // Converti le coordinate nel sistema della targetView
        let convertedPoint = target.convert(point, from: self)
        
        // Se il tap è dentro la targetView, lascia che gestisca l'evento
        if target.bounds.contains(convertedPoint) {
            return target.hitTest(convertedPoint, with: event)
        }
        
        // Altrimenti, lascia passare il tap a Flutter sotto
        return nil
    }
}

/// Controller nativo che mostra una UITabBar translucida con blur (stile iOS 26)
final class NativeGlassTabBarController: UIViewController, UITabBarDelegate {
    private let tabBar = UITabBar()
    private var items: [UITabBarItem] = []
    private var channel: FlutterMethodChannel?
    private var isShown: Bool = true

    // MARK: - Appearance Configuration
    
    /// Configura appearance in stile "Liquid Glass" iOS 26
    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        
        // Usa materiale blur nativo per fedeltà 100%
        appearance.configureWithDefaultBackground()
        
        // iOS 15+: effetto translucido + glass con thin material
        if #available(iOS 15.0, *) {
            appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        }
        
        // Tinta di background adattiva (light/dark mode)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.35)

        // Bordo superiore sottile per edge separation
        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.2)
        
        // Item text styling con colori dinamici
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance

        // Apply to all states
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.isTranslucent = true
        tabBar.delegate = self
        
        // Tint color per icone selezionate (Baumann primary blue)
        tabBar.tintColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    }

    // MARK: - Lifecycle
    
    override func loadView() {
        // Usa la custom PassthroughView invece di UIView standard
        let passthroughView = PassthroughView()
        passthroughView.backgroundColor = .clear
        passthroughView.targetView = tabBar
        self.view = passthroughView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        // Layout senza gap (attaccata al bordo)
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 49)
        ])

        // Rimuovo corner radius e shadow per stile standard iOS
        tabBar.layer.masksToBounds = false
    }

    // MARK: - Method Channel Wiring
    
    func attachChannel(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func setTabs(_ tabs: [[String: Any]]) {
        var newItems: [UITabBarItem] = []
        
        for tab in tabs {
            let title = tab["title"] as? String ?? ""
            let systemName = tab["systemIcon"] as? String
            
            let item: UITabBarItem
            if let name = systemName, let image = UIImage(systemName: name) {
                item = UITabBarItem(title: title, image: image, selectedImage: image)
            } else {
                item = UITabBarItem(title: title, image: nil, selectedImage: nil)
            }
            
            newItems.append(item)
        }
        
        items = newItems
        tabBar.items = items
        tabBar.selectedItem = items.first
    }

    func setSelectedIndex(_ index: Int) {
        guard index >= 0, index < items.count else { return }
        tabBar.selectedItem = items[index]
    }

    func show(_ show: Bool, animated: Bool = true) {
        guard isShown != show else { return }
        isShown = show
        
        let targetAlpha: CGFloat = show ? 1.0 : 0.0
        let targetTransform = show ? CGAffineTransform.identity : CGAffineTransform(translationX: 0, y: 12)
        
        if animated {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                self.tabBar.alpha = targetAlpha
                self.tabBar.transform = targetTransform
            } completion: { _ in
                self.channel?.invokeMethod("onVisibilityChanged", arguments: ["shown": show])
            }
        } else {
            tabBar.alpha = targetAlpha
            tabBar.transform = targetTransform
            channel?.invokeMethod("onVisibilityChanged", arguments: ["shown": show])
        }
    }

    // MARK: - UITabBarDelegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = items.firstIndex(of: item) else { return }
        channel?.invokeMethod("onTap", arguments: ["index": index])
    }
}
