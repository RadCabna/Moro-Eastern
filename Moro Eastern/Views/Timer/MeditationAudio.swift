import Foundation
import AVFoundation

/// Looped meditation audio with smooth fade-in / crossfade at loop boundaries.
final class MeditationAudio {

    // MARK: – Config
    private let fadeDuration: Double = 2.5  // seconds for each fade
    private let tickInterval:  Double = 0.05 // 20 fps

    // MARK: – State
    private var players:   [AVAudioPlayer?] = [nil, nil]
    private var activeIdx: Int = 0
    private var fileName:  String = ""
    private var ticker:    Timer?

    private var active: AVAudioPlayer? { players[activeIdx] }
    private var nextIdx: Int           { 1 - activeIdx }

    // MARK: – Public API

    func play(named name: String) {
        // Immediately cancel everything — no deferred timers
        cancelAll()

        fileName = name
        configureSession()

        loadPlayer(into: 0)
        players[0]?.volume = 0
        players[0]?.play()
        activeIdx = 0

        startTicker()
    }

    func stop() {
        // Grab current volumes before cancelling
        let snapA = players[0]?.volume ?? 0
        let snapB = players[1]?.volume ?? 0
        let pA = players[0]
        let pB = players[1]

        // Cancel tick so it doesn't interfere
        cancelAll()

        // Fade out on a one-shot timer (players captured by reference above)
        var step = 0
        let steps = 20
        Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { t in
            step += 1
            let ratio = Float(steps - step) / Float(steps)
            pA?.volume = snapA * ratio
            pB?.volume = snapB * ratio
            if step >= steps {
                t.invalidate()
                pA?.stop()
                pB?.stop()
            }
        }
    }

    // MARK: – Internals

    private func cancelAll() {
        ticker?.invalidate()
        ticker = nil
        players[0]?.stop(); players[0] = nil
        players[1]?.stop(); players[1] = nil
    }

    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func loadPlayer(into index: Int) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        players[index] = try? AVAudioPlayer(contentsOf: url)
        players[index]?.prepareToPlay()
    }

    private func startTicker() {
        ticker = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let cur = active else { return }

        // If player stopped unexpectedly, bail
        guard cur.isPlaying else { return }

        let elapsed  = cur.currentTime
        let duration = cur.duration
        let timeLeft = duration - elapsed

        // ── Fade in at start ───────────────────────────────────────────────
        if elapsed < fadeDuration && timeLeft >= fadeDuration {
            cur.volume = Float(elapsed / fadeDuration).clamped(to: 0...1)
            return
        }

        // ── Full volume in the middle ──────────────────────────────────────
        if timeLeft >= fadeDuration {
            cur.volume = 1.0
            return
        }

        // ── Crossfade near end ─────────────────────────────────────────────
        // Fade out current
        cur.volume = Float(timeLeft / fadeDuration).clamped(to: 0...1)

        // Start next player if not yet running
        if players[nextIdx] == nil {
            loadPlayer(into: nextIdx)
            players[nextIdx]?.volume = 0
            players[nextIdx]?.play()
        }

        // Fade in next
        if let nxt = players[nextIdx] {
            nxt.volume = Float(1.0 - timeLeft / fadeDuration).clamped(to: 0...1)
        }

        // Swap when current is essentially done
        if timeLeft < tickInterval * 2 {
            cur.stop()
            players[activeIdx] = nil
            activeIdx = nextIdx
        }
    }
}

// MARK: – Float helper
private extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
