import Foundation
 
struct DeezerTrackResponse: Codable {
    let data: [DeezerSong]
}

struct DeezerSong: Codable {
    let id: Int
    let title: String
    let preview: String
    let artist: DeezerArtist
    let album: DeezerAlbum
}

struct DeezerArtist: Codable {
    let name: String
}

struct DeezerAlbum: Codable {
    let cover_medium: String
}
 
struct SongOption: Identifiable, Equatable, Codable {
    let id = UUID()
    let title: String
    let artist: String
    let isCorrect: Bool
}

struct SongData: Codable, Identifiable {
    let id = UUID()
    let albumImage: String
    let musicFile: String
    let options: [SongOptionData]
}

struct SongOptionData: Codable {
    let title: String
    let artist: String
    let isCorrect: Bool
}

struct Artist: Codable {
    let name: String
}

struct Album: Codable {
    let cover_medium: String
}
