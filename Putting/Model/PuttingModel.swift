import Foundation

// MARK: - Settings types

enum Handedness: String, CaseIterable, Identifiable {
    case right, left
    var id: String { rawValue }
    var title: String { self == .right ? "Right" : "Left" }
}

enum DistanceUnit: String, CaseIterable, Identifiable {
    case feet, metres
    var id: String { rawValue }
    var title: String { self == .feet ? "Feet" : "Metres" }
    var short: String { self == .feet ? "ft" : "m" }
    func toFeet(_ value: Double) -> Double { self == .feet ? value : value / 0.3048 }
    func fromFeet(_ feet: Double) -> Double { self == .feet ? feet : feet * 0.3048 }
}

// MARK: - Zones

/// A vertical section of the foot. Its saved flat distance and the Stimp it was
/// saved at fix one release speed, which does not change with Stimp.
struct Zone: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var flatDistanceFt: Double?
    var stimp: Double?

    var isCalibrated: Bool {
        (flatDistanceFt ?? 0) > 0 && (stimp ?? 0) > 0
    }
}

// MARK: - Lookup

struct PuttInput {
    var stimp: Double
    var distanceFt: Double
    /// Fraction. Positive means the green falls to the right.
    var sideGrade: Double
    /// Fraction. Positive means uphill.
    var slopeGrade: Double
}

enum AimDirection {
    case left, right
    var letter: String { self == .left ? "L" : "R" }
}

struct Recommendation {
    var zone: Zone
    var aimFt: Double
    var aimDirection: AimDirection?
    var flatEquivalentFt: Double
    var targetOvershootFt: Double
    /// Negative means the ball finishes short of the hole.
    var actualOvershootFt: Double
    /// Set when the zone was saved at a different Stimp.
    var scaledFromStimp: Double?

    var overshootInWindow: Bool { (1.0...2.0).contains(actualOvershootFt) }
    var aimCups: Double { aimFt / PuttingModel.cupFt }
}

enum LookupOutcome {
    case recommendation(Recommendation)
    case notEnoughData
    case ballWillNotStop
}

/// Weber (1997), "Green Speed Physics", USGA Green Section Record:
///   f = 0.983 / S, deceleration on a grade = g (f ± sinφ cosφ).
/// Side slope uses the same friction: a ball released at v0 that reaches the
/// hole at vh needs an aim offset of
///   (a / c²) · [ (v0² − vh²)/4 − (vh²/2) · ln(v0 / vh) ],
/// with a = g · side grade and c = g (f ± sinφ cosφ).
enum PuttingModel {
    static let g = 32.2                 // ft/s²
    static let stimpConstant = 0.983    // ft, from the paper's 11.8 in
    static let cupFt = 4.25 / 12

    static func friction(stimp: Double) -> Double { stimpConstant / stimp }

    /// 10% of the putt, at least 1 ft and at most 2 ft.
    static func targetOvershoot(distanceFt d: Double) -> Double {
        min(2, max(1, 0.1 * d))
    }

    static func slopeTerm(_ grade: Double) -> Double {
        let phi = atan(grade)
        return sin(phi) * cos(phi)
    }

    /// v0² for a zone, in ft²/s². Independent of the Stimp it is used at.
    static func zoneSpeedSquared(_ zone: Zone) -> Double? {
        guard zone.isCalibrated, let length = zone.flatDistanceFt, let stimp = zone.stimp else { return nil }
        return 2 * g * friction(stimp: stimp) * length
    }

    static func releaseSpeed(_ zone: Zone) -> Double? {
        zoneSpeedSquared(zone).map { $0.squareRoot() }
    }

    static func lookup(_ putt: PuttInput, zones: [Zone]) -> LookupOutcome {
        let f = friction(stimp: putt.stimp)
        let k = f + slopeTerm(putt.slopeGrade)
        guard k > 0 else { return .ballWillNotStop }
        let c = g * k

        let target = targetOvershoot(distanceFt: putt.distanceFt)
        let roll = putt.distanceFt + target
        let requiredSpeed = (2 * c * roll).squareRoot()

        let candidates = zones.compactMap { zone in zoneSpeedSquared(zone).map { (zone, $0) } }
        guard let best = candidates.min(by: {
            abs($0.1.squareRoot() - requiredSpeed) < abs($1.1.squareRoot() - requiredSpeed)
        }) else { return .notEnoughData }

        let v0sq = best.1
        let actualRoll = v0sq / (2 * c)
        let vhsq = max(0, v0sq - 2 * c * putt.distanceFt)

        var aim = 0.0
        let a = g * abs(putt.sideGrade)
        if a > 0 {
            var term = (v0sq - vhsq) / 4
            if vhsq > 1e-9 {
                term -= (vhsq / 2) * log((v0sq / vhsq).squareRoot())
            }
            aim = a / (c * c) * term
        }

        let direction: AimDirection? = putt.sideGrade > 0 ? .left : (putt.sideGrade < 0 ? .right : nil)
        var scaled: Double? = nil
        if let saved = best.0.stimp, abs(saved - putt.stimp) > 0.01 { scaled = saved }

        return .recommendation(Recommendation(
            zone: best.0,
            aimFt: aim,
            aimDirection: direction,
            flatEquivalentFt: roll * k / f,
            targetOvershootFt: target,
            actualOvershootFt: actualRoll - putt.distanceFt,
            scaledFromStimp: scaled
        ))
    }
}

// MARK: - Formatting

func formatted(_ value: Double, digits: Int = 1) -> String {
    value.formatted(.number.precision(.fractionLength(digits)))
}

func parseNumber(_ text: String) -> Double? {
    Double(text.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
}
