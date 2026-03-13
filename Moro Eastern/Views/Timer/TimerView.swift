import SwiftUI
import Combine

struct TimerView: View {

    // MARK: – Data
    private let durations = [5, 10, 20]
    private let sounds: [(icon: String, name: String, audio: String)] = [
        ("desertIcon", "Desert Wind", "desertMP"),
        ("camelIcon",  "Camel Steps", "camelMP"),
        ("muteIcon",   "Silence",     "")
    ]

    // Animation constants
    private let fps:           Double = 30
    private let arcDegsPerSec: Double = 28   // full rotation ≈ 13 s
    private let dotDegsPerSec: Double = 72   // full rotation ≈ 5 s
    private let dotCount:      Int    = 10
    private let dotSpread:     Double = 36   // 360 / 10 = равномерно по всей окружности

    // MARK: – Countdown state
    @State private var selectedDuration = 1        // index → 10 MIN default
    @State private var selectedSound    = 0
    @State private var isRunning        = false
    @State private var timeRemaining    = 10 * 60  // seconds
    @State private var countCancellable: AnyCancellable?

    // MARK: – Audio
    @State private var audio = MeditationAudio()

    // MARK: – Animation state
    @State private var animTick:       Double = 0  // cumulative, never resets
    @State private var animCancellable: AnyCancellable?

    // Derived angles from tick (freeze automatically when animTimer stops)
    private var arcRotation: Double { animTick / fps * arcDegsPerSec }
    private var dotRotation: Double { animTick / fps * dotDegsPerSec }

    // MARK: – Computed helpers
    private var totalSeconds: Int { durations[selectedDuration] * 60 }

    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: – Body
    var body: some View {
        VStack(spacing: 0) {
            header
            arcAnimation
            timeDisplay
            Spacer(minLength: screenHeight * 0.012)
            sessionSection
            Spacer(minLength: screenHeight * 0.016)
            atmosphereSection
            Spacer(minLength: screenHeight * 0.016)
            startButton
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.13)
        }
        .onChange(of: selectedSound) {
            guard isRunning else { return }
            let soundName = sounds[selectedSound].audio
            if soundName.isEmpty { audio.stop() }
            else                 { audio.play(named: soundName) }
        }
        .onDisappear {
            stopCountdown()
            stopAnimation()
            audio.stop()
        }
    }

    // MARK: – Header
    private var header: some View {
        Text("Timer")
            .font(.sfProSemibold(screenHeight * 0.025))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, screenHeight * 0.02)
            .padding(.bottom, screenHeight * 0.01)
    }

    // MARK: – Animated arc (between header and time)
    private var arcAnimation: some View {
        let radius:  CGFloat = screenHeight * 0.038
        let lineW:   CGFloat = screenHeight * 0.014
        let dotSize: CGFloat = screenHeight * 0.013
        let blue = Color(red: 0.18, green: 0.44, blue: 1.0)

        return ZStack {
            // Main arc with gap (gap ≈ 130° at top)
            Circle()
                .trim(from: 0.18, to: 0.82)
                .stroke(blue, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
                .rotationEffect(.degrees(-90 - arcRotation))
                .frame(width: radius * 2, height: radius * 2)

            // Orbiting dots — same size, no opacity variation
            ForEach(0..<dotCount, id: \.self) { i in
                let angleDeg = dotRotation - 90.0 - Double(i) * dotSpread
                let angleRad = angleDeg * .pi / 180.0

                Circle()
                    .fill(blue)
                    .frame(width: dotSize, height: dotSize)
                    .offset(x: radius * cos(angleRad),
                            y: radius * sin(angleRad))
                    .opacity(isRunning ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.35), value: isRunning)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
        .padding(.vertical, screenHeight * 0.012)
    }

    // MARK: – Time display (below the arc)
    private var timeDisplay: some View {
        Text(timeString)
            .font(.sfProSemibold(screenHeight * 0.085))
            .foregroundColor(.white)
            .monospacedDigit()
    }

    // MARK: – Session Length
    private var sessionSection: some View {
        VStack(spacing: screenHeight * 0.018) {
            Text("SESSION LENGTH")
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white.opacity(0.55))
                .tracking(1.5)

            HStack(spacing: 0) {
                ForEach(durations.indices, id: \.self) { idx in
                    Button {
                        guard !isRunning else { return }
                        selectedDuration = idx
                        timeRemaining = durations[idx] * 60
                    } label: {
                        Text("\(durations[idx]) MIN")
                            .font(.sfProSemibold(screenHeight * 0.018))
                            .foregroundColor(selectedDuration == idx ? .white : .white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .frame(height: screenHeight * 0.052)
                            .background(
                                RoundedRectangle(cornerRadius: screenHeight * 0.026)
                                    .fill(selectedDuration == idx
                                          ? Color(red: 0.18, green: 0.44, blue: 1.0)
                                          : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.026)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: screenHeight * 0.026)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            .padding(.horizontal, screenHeight * 0.025)
        }
    }

    // MARK: – Atmosphere
    private var atmosphereSection: some View {
        VStack(spacing: screenHeight * 0.018) {
            Text("ATMOSPHERE")
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white.opacity(0.55))
                .tracking(1.5)

            HStack(spacing: screenHeight * 0.04) {
                ForEach(sounds.indices, id: \.self) { idx in
                    soundButton(idx: idx)
                }
            }
        }
    }

    private func soundButton(idx: Int) -> some View {
        let selected = selectedSound == idx
        return Button {
            selectedSound = idx
        } label: {
            VStack(spacing: screenHeight * 0.012) {
                ZStack {
                    Circle()
                        .fill(selected
                              ? Color(red: 0.18, green: 0.44, blue: 1.0)
                              : Color.white.opacity(0.09))
                        .frame(width: screenHeight * 0.085, height: screenHeight * 0.085)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(selected ? 0 : 0.13), lineWidth: 1)
                        )

                    Image(sounds[idx].icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                        .colorMultiply(.white)
                }

                Text(sounds[idx].name)
                    .font(.sfProSemibold(screenHeight * 0.016))
                    .foregroundColor(.white.opacity(selected ? 1.0 : 0.55))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: – Start / Pause button
    private var startButton: some View {
        Button {
            if isRunning { pause() } else { start() }
        } label: {
            HStack(spacing: screenHeight * 0.016) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: screenHeight * 0.02, weight: .bold))
                Text(isRunning ? "PAUSE MEDITATION" : "START MEDITATION")
                    .font(.sfProSemibold(screenHeight * 0.02))
                    .tracking(1.2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: screenHeight * 0.068)
            .background(Capsule().fill(Color(red: 0.18, green: 0.44, blue: 1.0)))
        }
        .buttonStyle(.plain)
        .disabled(timeRemaining == 0)
        .opacity(timeRemaining == 0 ? 0.45 : 1.0)
    }

    // MARK: – Controls
    private func start() {
        isRunning = true
        startCountdown()
        startAnimation()
        let soundName = sounds[selectedSound].audio
        if !soundName.isEmpty { audio.play(named: soundName) }
    }

    private func pause() {
        isRunning = false
        stopCountdown()
        stopAnimation()
        audio.stop()
    }

    // MARK: – Countdown timer (1 s ticks)
    private func startCountdown() {
        countCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    pause()
                }
            }
    }

    private func stopCountdown() {
        countCancellable?.cancel()
        countCancellable = nil
    }

    // MARK: – Animation timer (~30 fps)
    private func startAnimation() {
        animCancellable = Timer.publish(every: 1.0 / fps, on: .main, in: .common)
            .autoconnect()
            .sink { _ in animTick += 1 }
    }

    private func stopAnimation() {
        animCancellable?.cancel()
        animCancellable = nil
        // animTick is intentionally NOT reset so angles freeze at current position
    }
}

#Preview {
    ZStack {
        Image("background")
            .resizable()
            .ignoresSafeArea()
        TimerView()
    }
}
