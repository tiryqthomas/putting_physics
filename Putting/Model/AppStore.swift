import SwiftUI

final class AppStore: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var zones: [Zone] {
        didSet {
            if let data = try? JSONEncoder().encode(zones) { defaults.set(data, forKey: "zones") }
        }
    }
    @Published var handedness: Handedness {
        didSet { defaults.set(handedness.rawValue, forKey: "handedness") }
    }
    @Published var unit: DistanceUnit {
        didSet { defaults.set(unit.rawValue, forKey: "unit") }
    }
    /// Nil until a pace length is entered.
    @Published var paceLengthFt: Double? {
        didSet { defaults.set(paceLengthFt, forKey: "paceLengthFt") }
    }
    @Published var tempoBPM: Int {
        didSet { defaults.set(tempoBPM, forKey: "tempoBPM") }
    }

    init() {
        if let data = defaults.data(forKey: "zones"),
           let saved = try? JSONDecoder().decode([Zone].self, from: data) {
            zones = saved
        } else {
            zones = [Zone(name: "Inside"), Zone(name: "Center"), Zone(name: "Outside")]
        }
        handedness = Handedness(rawValue: defaults.string(forKey: "handedness") ?? "") ?? .right
        unit = DistanceUnit(rawValue: defaults.string(forKey: "unit") ?? "") ?? .feet
        paceLengthFt = defaults.object(forKey: "paceLengthFt") as? Double
        let bpm = defaults.integer(forKey: "tempoBPM")
        tempoBPM = bpm == 0 ? 72 : bpm
    }

    func length(_ feet: Double) -> String {
        unit == .feet
            ? "\(formatted(feet)) ft"
            : "\(formatted(unit.fromFeet(feet), digits: 2)) m"
    }
}
