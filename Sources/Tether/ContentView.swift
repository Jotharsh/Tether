import SwiftUI

struct ContentView: View {
    @Environment(WorkspaceStore.self) private var store
    @State private var showingCapture = false

    var body: some View {
        @Bindable var store = store
        HStack(spacing: 0) {
            Sidebar(showingCapture: $showingCapture)
            VStack(spacing: 0) {
                TopBar(showingCapture: $showingCapture)
                ZStack {
                    Color.tetherCanvas
                    if let workspace = store.selectedWorkspace {
                        WorkspaceDetail(workspace: workspace, showingCapture: $showingCapture)
                    } else {
                        FirstRoom(showingCapture: $showingCapture)
                    }
                }
            }
        }
        .background(Color.tetherBase)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingCapture) { CaptureRoomSheet() }
        .alert("Tether couldn't finish that", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
            Button("Open Accessibility Settings") { AccessibilityWorkspace.requestAccess() }
            Button("OK", role: .cancel) { store.errorMessage = nil }
        } message: { Text(store.errorMessage ?? "") }
    }
}

private struct Sidebar: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var showingCapture: Bool

    var body: some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                TetherMark(size: 28)
                Text("tether").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundStyle(Color.tetherText)
            }
            .padding(.horizontal, 22).padding(.top, 24).padding(.bottom, 42)

            Text("Your rooms").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.tetherFaint).padding(.horizontal, 22).padding(.bottom, 10)
            ScrollView {
                VStack(spacing: 5) {
                    if store.workspaces.isEmpty {
                        Text("Nothing saved yet.").font(.system(size: 13)).foregroundStyle(Color.tetherFaint).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 22).padding(.vertical, 8)
                    }
                    ForEach(store.workspaces) { workspace in
                        Button { store.selectedID = workspace.id } label: {
                            HStack(spacing: 10) {
                                Image(systemName: workspace.symbol).font(.system(size: 14, weight: .medium)).frame(width: 18).foregroundStyle(workspace.color.swiftUIColor)
                                Text(workspace.name).lineLimit(1)
                                Spacer()
                                Text("\(workspace.windows.count)").font(.system(size: 12, design: .rounded)).foregroundStyle(Color.tetherFaint)
                            }
                            .foregroundStyle(Color.tetherText).padding(.horizontal, 12).frame(height: 40)
                            .background(store.selectedID == workspace.id ? Color.tetherSelected : .clear, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 10)
            }

            VStack(alignment: .leading, spacing: 12) {
                Button { showingCapture = true } label: { Label("Save this room", systemImage: "plus") }
                    .buttonStyle(TetherButtonStyle())
                Label("Stored only on this Mac", systemImage: "lock.fill")
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(Color.tetherFaint)
            }.padding(18)
        }
        .frame(width: 238).background(Color.tetherBase)
    }
}

private struct TopBar: View {
    @Binding var showingCapture: Bool
    var body: some View {
        HStack(spacing: 12) {
            Text("Rooms").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.tetherText)
            Spacer()
            Text("Window arrangements, right where you left them.").font(.system(size: 13)).foregroundStyle(Color.tetherFaint)
            Spacer()
            Button { showingCapture = true } label: { Image(systemName: "plus").font(.system(size: 13, weight: .bold)) }
                .buttonStyle(.plain).foregroundStyle(Color.tetherText).frame(width: 32, height: 32).background(Color.tetherSelected, in: Circle())
        }
        .padding(.horizontal, 30).frame(height: 60).background(Color.tetherBase)
    }
}

private struct FirstRoom: View {
    @Binding var showingCapture: Bool
    var body: some View {
        HStack(spacing: 54) {
            VStack(alignment: .leading, spacing: 20) {
                Text("A room for\nhow you work.")
                    .font(.system(size: 48, weight: .semibold, design: .rounded)).tracking(-1.3).foregroundStyle(Color.tetherText)
                Text("Save the exact set of windows that belongs to a task. Tether brings that room back when it is time to return.")
                    .font(.system(size: 16)).foregroundStyle(Color.tetherMist).lineSpacing(4).frame(maxWidth: 365, alignment: .leading)
                Button("Save the windows open now") { showingCapture = true }
                    .buttonStyle(TetherButtonStyle()).padding(.top, 5)
                HStack(spacing: 18) {
                    MiniPromise(symbol: "rectangle.3.group", title: "Your layout")
                    MiniPromise(symbol: "lock.fill", title: "Local only")
                }.padding(.top, 12)
            }.frame(maxWidth: 445, alignment: .leading)
            RoomPlan().frame(maxWidth: 480)
        }
        .frame(maxWidth: 1050, maxHeight: .infinity, alignment: .center).padding(.horizontal, 54)
    }
}

private struct MiniPromise: View {
    let symbol: String; let title: String
    var body: some View {
        HStack(spacing: 7) { Image(systemName: symbol).font(.system(size: 12)).foregroundStyle(Color.tetherTeal); Text(title).font(.system(size: 12, weight: .medium)).foregroundStyle(Color.tetherMist) }
    }
}

private struct RoomPlan: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.tetherSurface)
            WindowPreview(title: "Project notes", app: "Notes", icon: "note.text", color: .tetherAmber).frame(width: 215, height: 172).offset(x: -100, y: -85)
            WindowPreview(title: "Tether", app: "Xcode", icon: "hammer.fill", color: .tetherCobalt).frame(width: 305, height: 240).offset(x: 46, y: -31)
            WindowPreview(title: "Build log", app: "Terminal", icon: "terminal.fill", color: .tetherTeal).frame(width: 250, height: 148).offset(x: -55, y: 60)
            VStack(alignment: .leading, spacing: 5) { Text("A saved room").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.tetherText); Text("Three windows, back in place.").font(.system(size: 12)).foregroundStyle(Color.tetherFaint) }.padding(24)
        }.frame(height: 360)
    }
}

private struct WindowPreview: View {
    let title: String; let app: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) { Circle().fill(color).frame(width: 7, height: 7); Text(app).font(.system(size: 10, weight: .medium)).foregroundStyle(Color.tetherFaint); Spacer(); Image(systemName: "ellipsis").font(.system(size: 10)).foregroundStyle(Color.tetherFaint) }.padding(12)
            Spacer()
            VStack(alignment: .leading, spacing: 7) { Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color); Text(title).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.tetherText) }.padding(14)
        }
        .background(Color.tetherWindow, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.tetherStroke, lineWidth: 1))
    }
}

private struct WorkspaceDetail: View {
    @Environment(WorkspaceStore.self) private var store
    let workspace: Workspace
    @Binding var showingCapture: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) { Text("Saved room").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.tetherFaint); HStack(spacing: 10) { Image(systemName: workspace.symbol).foregroundStyle(workspace.color.swiftUIColor); Text(workspace.name).font(.system(size: 34, weight: .semibold, design: .rounded)).tracking(-0.6).foregroundStyle(Color.tetherText) } }
                Spacer()
                Button(store.isWorking ? "Restoring…" : "Restore room") { store.restore(workspace) }.buttonStyle(TetherButtonStyle()).disabled(store.isWorking)
            }.padding(.bottom, 32)

            HStack(spacing: 10) { Metric(value: "\(workspace.windows.count)", label: "windows"); Metric(value: "\(Set(workspace.windows.map(\.bundleIdentifier)).count)", label: "apps"); Metric(value: workspace.updatedAt.formatted(.dateTime.month(.abbreviated).day()), label: "last saved") }.padding(.bottom, 34)
            HStack { Text("Windows in this room").font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.tetherText); Spacer(); Menu { Button("Save another room") { showingCapture = true }; Divider(); Button("Delete room", role: .destructive) { store.delete(workspace) } } label: { Image(systemName: "ellipsis").foregroundStyle(Color.tetherMist).frame(width: 28, height: 28).background(Color.tetherSelected, in: Circle()) }.menuStyle(.borderlessButton) }.padding(.bottom, 12)
            ScrollView { LazyVStack(spacing: 8) { ForEach(workspace.windows) { WindowRow(window: $0, color: workspace.color) } } }
        }.padding(38).frame(maxWidth: 1060, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct Metric: View {
    let value: String; let label: String
    var body: some View { VStack(alignment: .leading, spacing: 4) { Text(value).font(.system(size: 25, weight: .semibold, design: .rounded)).foregroundStyle(Color.tetherText).monospacedDigit(); Text(label).font(.system(size: 12)).foregroundStyle(Color.tetherFaint) }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(Color.tetherSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous)) }
}

private struct WindowRow: View {
    let window: SavedWindow; let color: WorkspaceColor
    var body: some View { HStack(spacing: 13) { Image(systemName: "macwindow").font(.system(size: 15)).foregroundStyle(color.swiftUIColor).frame(width: 22); VStack(alignment: .leading, spacing: 3) { Text(window.title).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.tetherText).lineLimit(1); Text(window.applicationName).font(.system(size: 12)).foregroundStyle(Color.tetherFaint) }; Spacer(); Text("\(Int(window.width)) × \(Int(window.height))").font(.system(size: 11, design: .rounded)).foregroundStyle(Color.tetherFaint) }.padding(.horizontal, 16).frame(height: 62).background(Color.tetherSurface, in: RoundedRectangle(cornerRadius: 13, style: .continuous)) }
}

private struct CaptureRoomSheet: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var color = WorkspaceColor.teal
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            TetherMark(size: 32)
            Text("Save this room").font(.system(size: 29, weight: .semibold, design: .rounded))
            Text("Tether will remember the size and position of the windows open right now.").font(.system(size: 14)).foregroundStyle(Color.tetherMist)
            TextField("Name this room", text: $name).textFieldStyle(.roundedBorder)
            HStack(spacing: 11) { ForEach(WorkspaceColor.allCases) { choice in Button { color = choice } label: { Circle().fill(choice.swiftUIColor).frame(width: 26, height: 26).overlay { if color == choice { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white) } } }.buttonStyle(.plain) } }
            HStack { Spacer(); Button("Cancel", role: .cancel) { dismiss() }; Button("Save room") { store.capture(name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled room" : name, symbol: "rectangle.3.group", color: color); if store.errorMessage == nil { dismiss() } }.buttonStyle(TetherButtonStyle()) }
        }.padding(28).frame(width: 410).background(Color.tetherCanvas)
    }
}

private struct TetherMark: View {
    let size: CGFloat
    var body: some View { ZStack { RoundedRectangle(cornerRadius: size * 0.31, style: .continuous).fill(Color.tetherTeal); Path { path in path.move(to: CGPoint(x: size * 0.28, y: size * 0.31)); path.addLine(to: CGPoint(x: size * 0.72, y: size * 0.31)); path.move(to: CGPoint(x: size * 0.50, y: size * 0.31)); path.addLine(to: CGPoint(x: size * 0.50, y: size * 0.72)); path.move(to: CGPoint(x: size * 0.28, y: size * 0.72)); path.addLine(to: CGPoint(x: size * 0.72, y: size * 0.72)) }.stroke(Color.tetherBase, style: StrokeStyle(lineWidth: max(1.7, size * 0.09), lineCap: .round, lineJoin: .round)) }.frame(width: size, height: size) }
}

private struct TetherButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.tetherBase).padding(.horizontal, 16).frame(height: 40).background(configuration.isPressed ? Color.tetherTeal.opacity(0.78) : Color.tetherTeal, in: RoundedRectangle(cornerRadius: 10, style: .continuous)) }
}

private extension WorkspaceColor { var swiftUIColor: Color { switch self { case .teal: .tetherTeal; case .cobalt: .tetherCobalt; case .plum: .tetherPlum; case .amber: .tetherAmber } } }
private extension Color {
    static let tetherBase = Color(red: 0.055, green: 0.063, blue: 0.073)
    static let tetherCanvas = Color(red: 0.078, green: 0.09, blue: 0.105)
    static let tetherSurface = Color(red: 0.105, green: 0.12, blue: 0.14)
    static let tetherWindow = Color(red: 0.125, green: 0.143, blue: 0.165)
    static let tetherSelected = Color(red: 0.16, green: 0.18, blue: 0.205)
    static let tetherStroke = Color(red: 0.22, green: 0.24, blue: 0.27)
    static let tetherText = Color(red: 0.94, green: 0.95, blue: 0.96)
    static let tetherMist = Color(red: 0.66, green: 0.69, blue: 0.73)
    static let tetherFaint = Color(red: 0.45, green: 0.49, blue: 0.54)
    static let tetherTeal = Color(red: 0.22, green: 0.82, blue: 0.72)
    static let tetherCobalt = Color(red: 0.37, green: 0.54, blue: 1)
    static let tetherPlum = Color(red: 0.72, green: 0.48, blue: 0.96)
    static let tetherAmber = Color(red: 0.96, green: 0.63, blue: 0.25)
}
