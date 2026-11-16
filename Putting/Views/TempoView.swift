import SwiftUI
import UIKit
import AudioToolbox

struct TempoView: View {
    @EnvironmentObject private var store: AppStore
    @State private var playing = false
    @State private var sound = true
    @State private var pulse = false
    @State private var task: Task<Void, Never>?

    private let range = 40...160

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { sound.toggle() } label: {
                    Label("Sound", systemImage: sound ? "speaker.wave.2" : "speaker.slash")
                }
                .buttonStyle(.glass)
            }

            Spacer()

            HStack(spacing: 20) {
                step("minus", by: -1)
                Text("\(store.tempoBPM)")
                    .font(.system(size: 88, weight: .semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .frame(minWidth: 170)
                step("plus", by: 1)
            }
            Text("BPM")
                .font(.footnote.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            Circle()
                .fill(pulse ? Color.primary : Color.secondary.opacity(0.35))
                .frame(width: 12, height: 12)
                .scaleEffect(pulse ? 1.6 : 1)
                .padding(.top, 32)

            Spacer()

            Button { playing ? stop() : start() } label: {
                Text(playing ? "Stop" : "Start")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .navigationTitle("Tempo")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { stop() }
    }

    private func step(_ symbol: String, by delta: Int) -> some View {
        Button {
            withAnimation(.snappy) {
                store.tempoBPM = min(range.upperBound, max(range.lowerBound, store.tempoBPM + delta))
            }
        } label: {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .buttonRepeatBehavior(.enabled)
        .accessibilityLabel(delta > 0 ? "Increase" : "Decrease")
    }

    private func start() {
        playing = true
        let haptic = UIImpactFeedbackGenerator(style: .rigid)
        haptic.prepare()
        task = Task { @MainActor in
            var next = ContinuousClock.now
            while !Task.isCancelled {
                if sound { AudioServicesPlaySystemSound(1104) }
                haptic.impactOccurred()
                withAnimation(.easeOut(duration: 0.06)) { pulse = true }
                withAnimation(.easeIn(duration: 0.2).delay(0.08)) { pulse = false }
                next = next.advanced(by: .seconds(60.0 / Double(store.tempoBPM)))
                try? await Task.sleep(until: next, clock: .continuous)
            }
        }
    }

    private func stop() {
        task?.cancel()
        task = nil
        playing = false
        pulse = false
    }
}
