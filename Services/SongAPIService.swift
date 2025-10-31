import Foundation

// MARK: - Playlist IDs
let playlistIds: [String: [String: String]] = [
    "Turkish": [
        "Pop": "14482387503",
        "Rap": "14482449143",
        "Rock": "14482438883",
    ],
    "English": [
        "Pop": "14482459723",
        "Rap": "14482469083",
        "Rock": "14482472563",
    ]
]

// MARK: - Public API
func fetchSongList(language: String, category: String, completion: @escaping ([SongData]) -> Void) {
    guard let playlistId = playlistIds[language]?[category] else {
        print("⚠️ No playlist found for \(language) - \(category)")
        completion([])
        return
    }
 
    guard let url = URL(string: "https://api.deezer.com/playlist/\(playlistId)/tracks?index=0&limit=200") else {
        print("❌ Invalid URL for playlist \(playlistId)")
        completion([])
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print("❌ Network error:", error?.localizedDescription ?? "Unknown")
            completion([])
            return
        }

        do {
            let response = try JSONDecoder().decode(DeezerTrackResponse.self, from: data)
            let allTracks = response.data.filter { !$0.preview.isEmpty }

            guard !allTracks.isEmpty else {
                print("⚠️ Playlist \(playlistId) boş veya preview yok.")
                completion([])
                return
            }

            let selectedTracks = Array(allTracks.shuffled().prefix(5))
 
            var songList: [SongData] = []
            for correctSong in selectedTracks {
                let wrongSongs = allTracks
                    .filter { $0.id != correctSong.id }
                    .shuffled()
                    .prefix(3)

                var options: [SongOptionData] = []
                options.append(SongOptionData(title: correctSong.title, artist: correctSong.artist.name, isCorrect: true))
                for song in wrongSongs {
                    options.append(SongOptionData(title: song.title, artist: song.artist.name, isCorrect: false))
                }
                options.shuffle()

                let songData = SongData(
                    albumImage: correctSong.album.cover_medium,
                    musicFile: correctSong.preview,
                    options: options
                )
                songList.append(songData)
            }

            DispatchQueue.main.async {
                completion(songList)
            }

        } catch {
            print("❌ JSON Decode Error:", error.localizedDescription)
            completion([])
        }
    }.resume()
}

// MARK: - Helper
private func createSongData(from allSongs: [DeezerSong]) -> SongData? {
    guard let correctSong = allSongs.randomElement() else { return nil }
 
    let wrongSongs = allSongs
        .filter { $0.id != correctSong.id && !$0.preview.isEmpty }
        .shuffled()
        .prefix(3)
 
    var options: [SongOptionData] = []
    options.append(SongOptionData(title: correctSong.title, artist: correctSong.artist.name, isCorrect: true))
    for song in wrongSongs {
        options.append(SongOptionData(title: song.title, artist: song.artist.name, isCorrect: false))
    }

    options.shuffle()

    return SongData(
        albumImage: correctSong.album.cover_medium,
        musicFile: correctSong.preview,
        options: options
    )
}
