import Foundation

struct SavedWindow: Identifiable, Codable, Hashable {
    var id = UUID()
    var bundleIdentifier: String
    var applicationName: String
    var title: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

struct Workspace: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var symbol: String
    var color: WorkspaceColor
    var createdAt = Date()
    var updatedAt = Date()
    var windows: [SavedWindow]
}

enum WorkspaceColor: String, Codable, CaseIterable, Identifiable {
    case teal, cobalt, plum, amber
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}
