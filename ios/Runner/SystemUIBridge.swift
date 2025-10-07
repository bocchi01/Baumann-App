// SystemUIBridge.swift
// Baumann Posture App - Native iOS System UI Components Bridge
import UIKit
import Flutter
import UniformTypeIdentifiers

/// Bridge completo per componenti di sistema iOS 26 nativi
final class SystemUIBridge: NSObject {
    private let channel: FlutterMethodChannel
    private unowned let rootVC: UIViewController
    private var contextMenuCallbacks: [String: (Int) -> Void] = [:]
    private var datePickerCallback: ((String) -> Void)?
    
    init(messenger: FlutterBinaryMessenger, rootViewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "system_ui", binaryMessenger: messenger)
        self.rootVC = rootViewController
        super.init()
        channel.setMethodCallHandler(handle)
    }
    
    // MARK: - Method Call Handler
    
    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "share":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            share(args: args, result: result)
            
        case "actionSheet":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            actionSheet(args: args, result: result)
            
        case "alert":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            alert(args: args, result: result)
            
        case "datePicker":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            datePicker(args: args, result: result)
            
        case "contextMenu":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            contextMenu(args: args, result: result)
            
        case "haptic":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            haptic(args: args, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Share Sheet (UIActivityViewController)
    
    private func share(args: [String: Any], result: @escaping FlutterResult) {
        let text = args["text"] as? String
        let urlString = args["url"] as? String
        let subject = args["subject"] as? String
        var activityItems: [Any] = []
        
        if let t = text, !t.isEmpty { activityItems.append(t) }
        if let s = urlString, let u = URL(string: s) { activityItems.append(u) }
        
        // File attachments con validazione sicurezza
        if let files = args["files"] as? [String] {
            for path in files {
                let url = URL(fileURLWithPath: path)
                // Sanitization: solo file leggibili dentro app sandbox
                guard FileManager.default.isReadableFile(atPath: url.path),
                      url.path.contains(NSTemporaryDirectory()) ||
                      url.path.contains(NSHomeDirectory()) else {
                    continue
                }
                activityItems.append(url)
            }
        }
        
        // Immagini da data base64
        if let imageData = args["imageData"] as? FlutterStandardTypedData {
            if let image = UIImage(data: imageData.data) {
                activityItems.append(image)
            }
        }
        
        guard !activityItems.isEmpty else {
            result(FlutterError(code: "no_items", message: "No items to share", details: nil))
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Subject per email
        if let subj = subject {
            activityVC.setValue(subj, forKey: "subject")
        }
        
        // iPad popover
        if let pop = activityVC.popoverPresentationController {
            pop.sourceView = rootVC.view
            pop.sourceRect = CGRect(
                x: rootVC.view.bounds.midX,
                y: rootVC.view.bounds.maxY - 80,
                width: 1,
                height: 1
            )
            pop.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true) {
            result(nil)
        }
    }
    
    // MARK: - Action Sheet (UIAlertController)
    
    private func actionSheet(args: [String: Any], result: @escaping FlutterResult) {
        let title = args["title"] as? String
        let message = args["message"] as? String
        let actions = args["actions"] as? [[String: Any]] ?? []
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (idx, a) in actions.enumerated() {
            let label = a["label"] as? String ?? "Action \(idx + 1)"
            let styleRaw = a["style"] as? String ?? "default"
            let iconName = a["icon"] as? String
            
            let style: UIAlertAction.Style = {
                switch styleRaw {
                case "destructive": return .destructive
                case "cancel": return .cancel
                default: return .default
                }
            }()
            
            let action = UIAlertAction(title: label, style: style) { [weak self] _ in
                self?.channel.invokeMethod("onActionSelected", arguments: ["index": idx])
            }
            
            // SF Symbol icon (iOS 13+)
            if let icon = iconName, let image = UIImage(systemName: icon) {
                action.setValue(image, forKey: "image")
            }
            
            alert.addAction(action)
        }
        
        // iPad popover
        if let pop = alert.popoverPresentationController {
            pop.sourceView = rootVC.view
            pop.sourceRect = CGRect(
                x: rootVC.view.bounds.midX,
                y: rootVC.view.bounds.maxY - 80,
                width: 1,
                height: 1
            )
            pop.permittedArrowDirections = []
        }
        
        rootVC.present(alert, animated: true) {
            result(nil)
        }
    }
    
    // MARK: - Alert Dialog (UIAlertController)
    
    private func alert(args: [String: Any], result: @escaping FlutterResult) {
        let title = args["title"] as? String
        let message = args["message"] as? String
        let actions = args["actions"] as? [[String: Any]] ?? []
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (idx, a) in actions.enumerated() {
            let label = a["label"] as? String ?? "OK"
            let styleRaw = a["style"] as? String ?? "default"
            
            let style: UIAlertAction.Style = {
                switch styleRaw {
                case "destructive": return .destructive
                case "cancel": return .cancel
                default: return .default
                }
            }()
            
            let action = UIAlertAction(title: label, style: style) { [weak self] _ in
                self?.channel.invokeMethod("onAlertAction", arguments: ["index": idx])
            }
            
            alert.addAction(action)
        }
        
        rootVC.present(alert, animated: true) {
            result(nil)
        }
    }
    
    // MARK: - Date Picker (UIDatePicker in Sheet)
    
    private func datePicker(args: [String: Any], result: @escaping FlutterResult) {
        let mode = args["mode"] as? String ?? "date"
        let initialDate = args["initialDate"] as? String
        let minDate = args["minDate"] as? String
        let maxDate = args["maxDate"] as? String
        
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        
        // Mode
        switch mode {
        case "time":
            picker.datePickerMode = .time
        case "dateTime":
            picker.datePickerMode = .dateAndTime
        default:
            picker.datePickerMode = .date
        }
        
        // Initial date
        if let dateStr = initialDate, let date = ISO8601DateFormatter().date(from: dateStr) {
            picker.date = date
        }
        
        // Min/max dates
        if let minStr = minDate, let date = ISO8601DateFormatter().date(from: minStr) {
            picker.minimumDate = date
        }
        if let maxStr = maxDate, let date = ISO8601DateFormatter().date(from: maxStr) {
            picker.maximumDate = date
        }
        
        // Sheet container
        let container = UIViewController()
        container.view.backgroundColor = .systemBackground
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(dismissDatePicker)
            ),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(confirmDatePicker)
            )
        ]
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(toolbar)
        container.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: container.view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            
            picker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Store picker reference
        objc_setAssociatedObject(container, "picker", picker, .OBJC_ASSOCIATION_RETAIN)
        
        // Callback
        datePickerCallback = { [weak self] dateString in
            self?.channel.invokeMethod("onDateSelected", arguments: ["date": dateString])
        }
        
        // Present as sheet
        if #available(iOS 15.0, *) {
            if let sheet = container.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        rootVC.present(container, animated: true) {
            result(nil)
        }
    }
    
    @objc private func dismissDatePicker() {
        rootVC.dismiss(animated: true)
        channel.invokeMethod("onDateCancelled", arguments: nil)
    }
    
    @objc private func confirmDatePicker() {
        guard let presented = rootVC.presentedViewController,
              let picker = objc_getAssociatedObject(presented, "picker") as? UIDatePicker else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: picker.date)
        
        rootVC.dismiss(animated: true) { [weak self] in
            self?.datePickerCallback?(dateString)
        }
    }
    
    // MARK: - Context Menu (UIContextMenuInteraction)
    
    private func contextMenu(args: [String: Any], result: @escaping FlutterResult) {
        let menuId = args["menuId"] as? String ?? UUID().uuidString
        let items = args["items"] as? [[String: Any]] ?? []
        
        // Nota: questo richiede un overlay view in UIKit per ricevere l'interazione
        // Per ora, mostriamo come UIMenu in un alert-style
        // In produzione, servirebbe un PlatformView overlay con UIContextMenuInteraction
        
        result(FlutterError(
            code: "not_implemented",
            message: "Context menu requires PlatformView overlay",
            details: nil
        ))
    }
    
    // MARK: - Haptic Feedback
    
    private func haptic(args: [String: Any], result: @escaping FlutterResult) {
        let type = args["type"] as? String ?? "medium"
        
        switch type {
        case "light":
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case "medium":
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case "heavy":
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case "selection":
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case "success":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case "warning":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case "error":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        default:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        result(nil)
    }
}
