import Foundation
import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private init() {}

    private var player: AVAudioPlayer?

    func playEffect(named name: String, fileExtension: String = "mp3", loops: Int = 0, volume: Float = 1.0) {
        stop()
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("❌ Effect not found:", name)
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = loops
            p.volume = volume
            p.prepareToPlay()
            p.play()
            self.player = p
        } catch {
            print("❌ AudioManager error:", error.localizedDescription)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}