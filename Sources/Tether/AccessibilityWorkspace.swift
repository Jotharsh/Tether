import AppKit
import ApplicationServices
import Foundation

enum TetherError: LocalizedError {
    case permissionRequired, noWindows
    var errorDescription: String? {
        switch self {
        case .permissionRequired: return "Tether needs Accessibility access to read and arrange windows. Turn it on in System Settings, then return here."
        case .noWindows: return "Tether could not find any windows to save."
        }
    }
}

enum AccessibilityWorkspace {
    static var isTrusted: Bool { AXIsProcessTrusted() }

    static func requestAccess() {
        let option = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        AXIsProcessTrustedWithOptions([option: true] as CFDictionary)
    }

    static func captureWindows() throws -> [SavedWindow] {
        guard isTrusted else { throw TetherError.permissionRequired }
        let ownPID = ProcessInfo.processInfo.processIdentifier
        let applications = NSWorkspace.shared.runningApplications.filter {
            $0.processIdentifier != ownPID && $0.activationPolicy == .regular && $0.bundleIdentifier != nil
        }
        var saved: [SavedWindow] = []
        for application in applications {
            let axApp = AXUIElementCreateApplication(application.processIdentifier)
            for window in windows(of: axApp) {
                guard let frame = frame(of: window), frame.width > 40, frame.height > 40 else { continue }
                saved.append(SavedWindow(bundleIdentifier: application.bundleIdentifier ?? "", applicationName: application.localizedName ?? "App", title: stringValue(window, kAXTitleAttribute) ?? "Untitled window", x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height))
            }
        }
        guard !saved.isEmpty else { throw TetherError.noWindows }
        return saved
    }

    static func restore(_ savedWindows: [SavedWindow]) throws {
        guard isTrusted else { throw TetherError.permissionRequired }
        for saved in savedWindows {
            guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == saved.bundleIdentifier }) else { continue }
            app.activate(options: [])
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            let candidate = windows(of: axApp).first { stringValue($0, kAXTitleAttribute) == saved.title } ?? windows(of: axApp).first
            guard let candidate else { continue }
            setFrame(CGRect(x: saved.x, y: saved.y, width: saved.width, height: saved.height), on: candidate)
        }
    }

    private static func windows(of application: AXUIElement) -> [AXUIElement] {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(application, kAXWindowsAttribute as CFString, &value) == .success, let array = value as? [AXUIElement] else { return [] }
        return array
    }

    private static func stringValue(_ element: AXUIElement, _ attribute: String) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else { return nil }
        return value as? String
    }

    private static func frame(of element: AXUIElement) -> CGRect? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue) == .success,
              let positionAX = positionValue as! AXValue?, let sizeAX = sizeValue as! AXValue? else { return nil }
        var point = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionAX, .cgPoint, &point), AXValueGetValue(sizeAX, .cgSize, &size) else { return nil }
        return CGRect(origin: point, size: size)
    }

    private static func setFrame(_ frame: CGRect, on element: AXUIElement) {
        var origin = frame.origin
        var size = frame.size
        if let point = AXValueCreate(.cgPoint, &origin) { AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, point) }
        if let dimensions = AXValueCreate(.cgSize, &size) { AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, dimensions) }
    }
}
