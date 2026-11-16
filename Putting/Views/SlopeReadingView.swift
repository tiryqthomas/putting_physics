import SwiftUI
import CoreMotion

struct SlopeReading: Equatable {
    /// Fraction. Positive means the green falls to the right.
    var side: Double
    /// Fraction. Positive means uphill toward the hole.
    var slope: Double
}

/// Reads the green's slope with the phone face up, top toward the hole.
/// The ring fills only while the phone is still; after 3 seconds the reading locks.
final class SlopeMeter: ObservableObject {
    @Published var progress: Double = 0
    @Published var reading: SlopeReading?
    @Published var available = true

    private let manager = CMMotionManager()
    private let rate = 30.0
    private let holdSeconds = 3.0
    private let stillness = 0.003          // grade change allowed within the window
    private var window: [SlopeReading] = []
    private var steady: [SlopeReading] = []

    func start() {
        guard manager.isDeviceMotionAvailable else { available = false; return }
        restart()
        manager.deviceMotionUpdateInterval = 1 / rate
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.handle(motion.gravity)
        }
    }

    func stop() { manager.stopDeviceMotionUpdates() }

    func restart() {
        reading = nil
        progress = 0
        window.removeAll()
        steady.removeAll()
    }

    private func handle(_ gravity: CMAcceleration) {
        guard reading == nil else { return }
        let flat = -gravity.z
        guard flat > 0.95 else { breakSteady(); return }   // face up, within about 18°

        let sample = SlopeReading(side: gravity.x / flat, slope: -gravity.y / flat)
        window.append(sample)
        if window.count > Int(rate / 2) { window.removeFirst() }

        let sides = window.map(\.side), slopes = window.map(\.slope)
        let still = window.count >= Int(rate / 2)
            && (sides.max()! - sides.min()!) < stillness
            && (slopes.max()! - slopes.min()!) < stillness
        guard still else { breakSteady(); return }

        steady.append(sample)
        progress = min(1, Double(steady.count) / (rate * holdSeconds))
        if progress >= 1 {
            let n = Double(steady.count)
            reading = SlopeReading(
                side: steady.map(\.side).reduce(0, +) / n,
                slope: steady.map(\.slope).reduce(0, +) / n
            )
            stop()
        }
    }

    private func breakSteady() {
        steady.removeAll()
        if progress != 0 { progress = 0 }
    }
}

struct SlopeReadingView: View {
    /// When set, the reading is returned and the screen closes after the check.
    var onComplete: ((SlopeReading) -> Void)? = nil

    @StateObject private var meter = SlopeMeter()
    @State private var showReading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle().stroke(.quaternary, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: meter.progress)
                    .stroke(.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.12), value: meter.progress)
                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .semibold))
                    .scaleEffect(meter.reading == nil ? 0.4 : 1)
                    .opacity(meter.reading == nil ? 0 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: meter.reading)
            }
            .frame(width: 180, height: 180)

            caption
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(height: 64)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .navigationTitle("Slope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if meter.reading != nil && onComplete == nil {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showReading.toggle() } label: {
                        Image(systemName: showReading ? "eye.slash" : "eye")
                    }
                    .accessibilityLabel("See reading")
                    Button {
                        showReading = false
                        meter.start()
                    } label: { Image(systemName: "arrow.counterclockwise") }
                    .accessibilityLabel("Redo")
                }
            }
        }
        .sensoryFeedback(.success, trigger: meter.reading) { _, new in new != nil }
        .onAppear { meter.start() }
        .onDisappear { meter.stop() }
        .onChange(of: meter.reading) { _, reading in
            guard let reading, let onComplete else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                onComplete(reading)
                dismiss()
            }
        }
    }

    @ViewBuilder private var caption: some View {
        if !meter.available {
            Text("Motion data is unavailable on this device.")
        } else if let reading = meter.reading {
            if showReading {
                HStack(spacing: 32) {
                    value("Side", reading.side, positive: "R", negative: "L")
                    value("Up / down", reading.slope, positive: "U", negative: "D")
                }
                .foregroundStyle(.primary)
            } else {
                Color.clear
            }
        } else {
            Text("Place the phone face up, top toward the hole.")
        }
    }

    private func value(_ title: String, _ grade: Double, positive: String, negative: String) -> some View {
        VStack(spacing: 4) {
            Text("\(formatted(abs(grade) * 100))% \(grade >= 0 ? positive : negative)")
                .font(.title2.weight(.semibold).monospacedDigit())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}
