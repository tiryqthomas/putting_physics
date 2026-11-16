import SwiftUI

/// Stand-in for the Calibration flows: zone distances and pace length are
/// entered by hand until Zones and Pace calibration are built.
struct CalibrationView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Form {
            Section("Zones") {
                ForEach($store.zones) { $zone in
                    ZoneEditor(zone: $zone, unit: store.unit)
                }
                .onDelete { store.zones.remove(atOffsets: $0) }
                Button("Add Zone") {
                    store.zones.append(Zone(name: "Zone \(store.zones.count + 1)"))
                }
            }
            Section("Pace") {
                PaceEditor()
            }
        }
        .navigationTitle("Calibration")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ZoneEditor: View {
    @Binding var zone: Zone
    let unit: DistanceUnit
    @State private var distance = ""
    @State private var stimp = ""

    var body: some View {
        VStack(spacing: 10) {
            TextField("Name", text: $zone.name)
                .font(.headline)
            HStack {
                Text("Flat distance").foregroundStyle(.secondary)
                Spacer()
                TextField("–", text: $distance)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                Text(unit.short).foregroundStyle(.secondary)
            }
            HStack {
                Text("Stimp").foregroundStyle(.secondary)
                Spacer()
                TextField("–", text: $stimp)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            distance = zone.flatDistanceFt.map { formatted(unit.fromFeet($0), digits: unit == .feet ? 1 : 2) } ?? ""
            stimp = zone.stimp.map { formatted($0) } ?? ""
        }
        .onChange(of: distance) { _, text in zone.flatDistanceFt = parseNumber(text).map(unit.toFeet) }
        .onChange(of: stimp) { _, text in zone.stimp = parseNumber(text) }
    }
}

private struct PaceEditor: View {
    @EnvironmentObject private var store: AppStore
    @State private var text = ""

    var body: some View {
        HStack {
            Text("Pace length")
            Spacer()
            TextField("–", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(store.unit.short).foregroundStyle(.secondary)
        }
        .onAppear {
            text = store.paceLengthFt.map { formatted(store.unit.fromFeet($0), digits: 2) } ?? ""
        }
        .onChange(of: text) { _, value in
            store.paceLengthFt = parseNumber(value).flatMap { $0 > 0 ? store.unit.toFeet($0) : nil }
        }
    }
}
