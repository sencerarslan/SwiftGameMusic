import Foundation

enum HighScoreKeys {
    static let highScore = "HighScore"
}

final class HighScoreManager {
    static let shared = HighScoreManager()
    private init() {}

    var value: Int {
        get { UserDefaults.standard.integer(forKey: HighScoreKeys.highScore) }
        set { UserDefaults.standard.set(newValue, forKey: HighScoreKeys.highScore) }
    }

    func updateIfNeeded(with score: Int) {
        if score > value { value = score }
    }
}