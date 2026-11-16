import SwiftUI

enum Route: Hashable {
    case slope, tempo, lookup, calibration, settings
}

struct DashboardView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 8) {
                GlassCard {
                    DashRow(icon: "slider.horizontal.3", title: "Calibration", route: .calibration)
                    Divider()
                    DashRow(icon: "tablecells", title: "Lookup", route: .lookup)
                }

                SectionLabel("Tests").padding(.top, 16)
                GlassCard {
                    DashRow(icon: "metronome", title: "Tempo", route: .tempo)
                    Divider()
                    DashRow(icon: "hand.point.up", title: "Feel", route: nil)
                }

                SectionLabel("Practice").padding(.top, 16)
                GlassCard {
                    DashRow(icon: "target", title: "Zones", route: nil)
                    Divider()
                    DashRow(icon: "die.face.3", title: "Random putts", route: nil)
                    Divider()
                    DashRow(icon: "stopwatch", title: "Pace of play", route: nil)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .navigationTitle("Practice")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { path.append(.slope) } label: { Image(systemName: "level") }
                        .accessibilityLabel("Slope reading")
                    Button { path.append(.tempo) } label: { Image(systemName: "metronome") }
                        .accessibilityLabel("Metronome")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { path.append(.settings) } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .slope: SlopeReadingView()
                case .tempo: TempoView()
                case .lookup: LookupView()
                case .calibration: CalibrationView()
                case .settings: SettingsView()
                }
            }
        }
    }
}

private struct DashRow: View {
    let icon: String
    let title: String
    /// Nil for screens not yet built in this version.
    let route: Route?

    var body: some View {
        if let route {
            NavigationLink(value: route) { content(enabled: true) }
                .buttonStyle(.plain)
        } else {
            content(enabled: false)
        }
    }

    private func content(enabled: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            if enabled {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(height: 50)
        .contentShape(Rectangle())
        .opacity(enabled ? 1 : 0.35)
    }
}
