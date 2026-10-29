import Foundation
import Observation

@Observable
final class WorkspaceStore {
    private static let key = "tether.workspaces.v1"
    var workspaces: [Workspace] = [] { didSet { save() } }
    var selectedID: Workspace.ID?
    var errorMessage: String?
    var isWorking = false

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let saved = try? JSONDecoder().decode([Workspace].self, from: data) {
            workspaces = saved
            selectedID = saved.first?.id
        }
    }

    var selectedWorkspace: Workspace? {
        guard let selectedID else { return nil }
        return workspaces.first(where: { $0.id == selectedID })
    }

    func capture(name: String, symbol: String, color: WorkspaceColor) {
        isWorking = true
        defer { isWorking = false }
        do {
            let windows = try AccessibilityWorkspace.captureWindows()
            guard !windows.isEmpty else {
                errorMessage = "There are no app windows to save. Open the apps you want in this room, then try again."
                return
            }
            let workspace = Workspace(name: name, symbol: symbol, color: color, windows: windows)
            workspaces.insert(workspace, at: 0)
            selectedID = workspace.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore(_ workspace: Workspace) {
        isWorking = true
        defer { isWorking = false }
        do {
            try AccessibilityWorkspace.restore(workspace.windows)
            touch(workspace.id)
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(_ workspace: Workspace) {
        workspaces.removeAll { $0.id == workspace.id }
        if selectedID == workspace.id { selectedID = workspaces.first?.id }
    }

    private func touch(_ id: Workspace.ID) {
        guard let index = workspaces.firstIndex(where: { $0.id == id }) else { return }
        workspaces[index].updatedAt = .now
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(workspaces) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }
}
