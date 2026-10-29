import SwiftUI

@main
struct TetherApp: App {
    @State private var store = WorkspaceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .frame(minWidth: 900, minHeight: 620)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1120, height: 720)
    }
}
