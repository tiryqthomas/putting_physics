import SwiftUI
import UIKit

struct LookupView: View {
    @EnvironmentObject private var store: AppStore

    @State private var stimp = ""
    @State private var distance = ""
    @State private var inPaces = false
    @State private var side = ""
    @State private var sideRight = true
    @State private var slope = ""
    @State private var uphill = true
    @State private var measuring = false
    @FocusState private var focus: Field?

    private enum Field { case stimp, distance, side, slope }

    var body: some View {
        VStack(spacing: 0) {
            GlassCard {
                row("Stimp") { numberField($stimp, .stimp) }
                Divider()
                row("Distance") {
                    numberField($distance, .distance)
                    if store.paceLengthFt != nil {
                        ChipToggle(text: inPaces ? "paces" : store.unit.short) { inPaces.toggle() }
                    } else {
                        Text(store.unit.short).foregroundStyle(.secondary)
                    }
                }
                Divider()
                row("Side slope") {
                    numberField($side, .side)
                    Text("%").foregroundStyle(.secondary)
                    ChipToggle(text: sideRight ? "R" : "L") { sideRight.toggle() }
                    CircleIconButton(systemName: "level", label: "Measure slope") { measuring = true }
                }
                Divider()
                row("Up / down") {
                    numberField($slope, .slope)
                    Text("%").foregroundStyle(.secondary)
                    ChipToggle(text: uphill ? "U" : "D") { uphill.toggle() }
                    CircleIconButton(systemName: "level", label: "Measure slope") { measuring = true }
                }
            }

            SectionLabel("Recommendation")
                .padding(.top, 24)
                .padding(.bottom, 8)

            result
                .animation(.snappy, value: summary)

            Spacer()

            if case .recommendation(let rec) = outcome {
                Text("Flat equivalent \(store.length(rec.flatEquivalentFt))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .navigationTitle("Lookup")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
        .navigationDestination(isPresented: $measuring) {
            SlopeReadingView { apply($0) }
        }
    }

    // MARK: Form

    private func row<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            Text(title).lineLimit(1)
            Spacer(minLength: 8)
            content()
        }
        .frame(height: 52)
    }

    private func numberField(_ text: Binding<String>, _ field: Field) -> some View {
        TextField("–", text: text)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.body.weight(.semibold).monospacedDigit())
            .frame(width: 64)
            .focused($focus, equals: field)
    }

    private func apply(_ reading: SlopeReading) {
        side = formatted(abs(reading.side) * 100)
        sideRight = reading.side >= 0
        slope = formatted(abs(reading.slope) * 100)
        uphill = reading.slope >= 0
    }

    // MARK: Model

    private var input: PuttInput? {
        guard let s = parseNumber(stimp), s > 0,
              let d = parseNumber(distance), d > 0 else { return nil }
        let feet: Double
        if inPaces, let pace = store.paceLengthFt { feet = d * pace } else { feet = store.unit.toFeet(d) }
        let sideValue = (parseNumber(side) ?? 0) / 100
        let slopeValue = (parseNumber(slope) ?? 0) / 100
        return PuttInput(
            stimp: s,
            distanceFt: feet,
            sideGrade: sideRight ? sideValue : -sideValue,
            slopeGrade: uphill ? slopeValue : -slopeValue
        )
    }

    private var outcome: LookupOutcome? {
        input.map { PuttingModel.lookup($0, zones: store.zones) }
    }

    /// Changes whenever the shown result changes, for animation.
    private var summary: String {
        switch outcome {
        case .none: return "empty"
        case .notEnoughData: return "none"
        case .ballWillNotStop: return "stop"
        case .recommendation(let r): return "\(r.zone.id)\(formatted(r.aimFt, digits: 2))"
        }
    }

    // MARK: Result

    @ViewBuilder private var result: some View {
        switch outcome {
        case .none:
            Text("Enter the Stimp and distance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)

        case .notEnoughData:
            VStack(alignment: .leading, spacing: 6) {
                Text("Not enough data").font(.headline)
                Text("Save a distance for a zone to see a recommendation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                NavigationLink(value: Route.calibration) {
                    Text("Open Calibration")
                }
                .buttonStyle(.glass)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

        case .ballWillNotStop:
            Text("The ball will not stop on this slope.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)

        case .recommendation(let rec):
            VStack(spacing: 8) {
                VStack(spacing: 0) {
                    tableRow("Zone", rec.zone.name)
                    Divider()
                    tableRow("Aim", aimText(rec))
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )

                if !rec.overshootInWindow {
                    Text(rec.actualOvershootFt >= 0
                         ? "Finishes \(store.length(rec.actualOvershootFt)) past the hole."
                         : "Finishes \(store.length(-rec.actualOvershootFt)) short.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let saved = rec.scaledFromStimp {
                    Text("Scaled from Stimp \(formatted(saved)).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func tableRow(_ key: String, _ value: String) -> some View {
        HStack(spacing: 0) {
            Text(key)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.secondarySystemFill))
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(14)
        }
    }

    private func aimText(_ rec: Recommendation) -> String {
        guard let direction = rec.aimDirection else { return "Straight" }
        return "\(formatted(rec.aimCups)) cups · \(store.length(rec.aimFt)) \(direction.letter)"
    }
}
