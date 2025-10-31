import Foundation
import SwiftUI
import AVFoundation

@MainActor
final class GamePlayViewModel: ObservableObject {
    // Inputs
    let selectedLanguage: String
    let selectedCategory: String

    // Audio Engine
    var engine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    var timePitch = AVAudioUnitTimePitch()
    var lowPass = AVAudioUnitEQ(numberOfBands: 1)
    var audioFile: AVAudioFile?

    // State
    @Published var remainingTime = 30
    @Published var blurAmount: CGFloat = 30
    @Published var progress: CGFloat = 1.0
    var timer: Timer?
    @Published var selectedOption: SongOption? = nil
    @Published var currentScore = 0
    @Published var lastGain: Int? = nil
    @Published var gameEnded = false
    @Published var isSelectionLocked = false
    @Published var isTransitioning = false

    // Rounds
    @Published var currentRound = 1
    let totalRounds = 5
    @Published var highScore = HighScoreManager.shared.value

    // Data
    @Published var allSongs: [SongData] = []
    @Published var currentSong: SongData?
    @Published var options: [SongOption] = []
    @Published var correctOption: SongOption? = nil

    // Config
    let totalTime = 30
    let startTime: TimeInterval = 0

    init(selectedLanguage: String, selectedCategory: String) {
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = selectedCategory
    }
 
    // MARK: - Fetch Deezer Songs
    func loadSongsFromAPI() async {
        await MainActor.run {
            self.currentRound = 0
            self.gameEnded = false
            self.currentScore = 0
            self.allSongs = []
        }

        await withCheckedContinuation { continuation in
            fetchSongList(language: selectedLanguage, category: selectedCategory) { songs in
                DispatchQueue.main.async {
                    self.allSongs = songs
                    self.currentRound = 0
                    self.nextRound()
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Game Flow
    func nextRound() {
        guard !gameEnded else { return }
         
        isSelectionLocked = true
        withAnimation(.easeInOut(duration: 0.6)) { isTransitioning = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.loadNextSong()
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isTransitioning = false
            }
        }
    }

    private func loadNextSong() {
        guard !allSongs.isEmpty else { return }

        if currentRound >= totalRounds || currentRound >= allSongs.count {
            endGame()
            return
        }
 
        let newSong = allSongs[currentRound]

        blurAmount = CGFloat(totalTime)
        progress = 1.0

        withAnimation(.easeInOut(duration: 0.6)) {
            currentSong = newSong
        }

        options = newSong.options.map {
            SongOption(title: $0.title, artist: $0.artist, isCorrect: $0.isCorrect)
        }

        selectedOption = nil
        lastGain = nil

        startGame()
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isSelectionLocked = false
        }

        // 🔹 Round sayacını en sonda artır
        currentRound += 1
    }


    
    private func startGame() {
        stopGame()
        setupAudioEngine()
        playMusic()
        startTimer()
    }

    func stopGame() {
        timer?.invalidate()
        playerNode.stop()
        engine.stop()
    }

    private func endGame() {
        stopGame()
        HighScoreManager.shared.updateIfNeeded(with: currentScore)
        highScore = HighScoreManager.shared.value
        withAnimation(.easeInOut(duration: 0.6)) { gameEnded = true }
    }

    func restartGame() {
        withAnimation {
            currentScore = 0
            currentRound = 1
            gameEnded = false
        }
    }

    // MARK: - Audio Engine Setup (URL based)
    private func setupAudioEngine() {
        guard let song = currentSong, let fileURL = URL(string: song.musicFile) else {
            print("❌ Geçersiz şarkı URL:", currentSong?.musicFile ?? "nil")
            return
        }
 
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let audioData = try Data(contentsOf: fileURL)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("currentPreview.mp3")
                try audioData.write(to: tempURL)

                let audioFile = try AVAudioFile(forReading: tempURL)

                DispatchQueue.main.async {
                    self.audioFile = audioFile
                    self.configureAudioEngine(with: audioFile)
                }
            } catch {
                print("❌ Audio download/setup error:", error.localizedDescription)
            }
        }
    }

    private func configureAudioEngine(with file: AVAudioFile) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            guard let format = file.processingFormat as AVAudioFormat? else { return }

            engine.stop(); engine.reset()
            engine.attach(playerNode)
            engine.attach(timePitch)
            engine.attach(lowPass)
 
            timePitch.pitch = -500
            timePitch.rate = 0.85
            if let band = lowPass.bands.first {
                band.filterType = .lowPass
                band.frequency = 400
                band.bypass = false
            }

            engine.connect(playerNode, to: timePitch, format: format)
            engine.connect(timePitch, to: lowPass, format: format)
            engine.connect(lowPass, to: engine.mainMixerNode, format: format)

            engine.mainMixerNode.outputVolume = 1.0
            try engine.start()
 
            self.playMusic()
        } catch {
            print("❌ Engine setup error:", error.localizedDescription)
        }
    }


    private func playMusic() {
        guard let file = audioFile else { return }

        playerNode.stop()
        let sampleRate = file.processingFormat.sampleRate
        var startFrame = AVAudioFramePosition(startTime * sampleRate)
        if startFrame >= file.length { startFrame = 0 }

        let frameCount = AVAudioFrameCount(file.length - startFrame)
        playerNode.scheduleSegment(file, startingFrame: startFrame, frameCount: frameCount, at: nil, completionHandler: nil)
        playerNode.volume = 1.0
        playerNode.play()
    }

    // MARK: - Timer Logic
    private func startTimer() {
        remainingTime = totalTime
        blurAmount = CGFloat(remainingTime)
        progress = 1.0
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1
                self.blurAmount = CGFloat(self.remainingTime)
                self.progress = CGFloat(self.remainingTime) / CGFloat(self.totalTime)

                let fraction = Float(self.remainingTime) / Float(self.totalTime)
                self.lowPass.bands.first?.frequency = 400 + (16000 * (1 - fraction))
                self.timePitch.pitch = -500 * fraction
                self.timePitch.rate = 0.85 + (0.15 * (1 - fraction))
            } else {
                t.invalidate()
                self.playerNode.stop()
                if let correct = self.options.first(where: { $0.isCorrect }) {
                    self.correctOption = correct
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.correctOption = nil
                        self.nextRound()
                    }
                } else {
                    self.nextRound()
                }
            }
        }
    }

    // MARK: - Selection Logic
    func select(_ option: SongOption) {
        guard !isSelectionLocked else { return }
        isSelectionLocked = true
        selectedOption = option
        timer?.invalidate()

        withAnimation(.easeInOut(duration: 0.8)) { blurAmount = 0 }

        lowPass.bands.first?.frequency = 18000
        timePitch.pitch = 0
        timePitch.rate = 1.0

        var gain = 0
        if option.isCorrect {
            gain = (remainingTime * 10)
            currentScore += gain
        } else {
            if let correct = options.first(where: { $0.isCorrect }) {
                correctOption = correct
            }
        }

        lastGain = gain
        playerNode.volume = 0.8

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.3)) { self.lastGain = nil }
            self.correctOption = nil
            self.selectedOption = nil
            self.isSelectionLocked = false
            self.nextRound()
        }
    }
}
