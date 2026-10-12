import AVFoundation

/// Mia's recorded voice for the lines she speaks in the interview (ElevenLabs, the "Mia Voice"
/// voice on Eleven v4). A line without a recording is shown without sound.
@MainActor
final class MiaVoice {
    static let shared = MiaVoice()

    /// Recordings in the Voice folder, by the exact text of the line.
    private static let clips: [String: String] = [
        "Hi, I'm Mia.": "mia_hi",
    ]

    private var player: AVAudioPlayer?

    /// Plays `text` if Mia has a recording of it, even with the ring switch on silent.
    /// Returns how long it lasts in seconds, or 0 when there is no recording.
    @discardableResult
    func say(_ text: String) -> Double {
        guard let name = Self.clips[text],
              let url = Bundle.main.url(forResource: name, withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return 0 }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.player = player
        player.play()
        return player.duration
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
