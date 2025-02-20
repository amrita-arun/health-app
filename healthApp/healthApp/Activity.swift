import Foundation

struct Activity: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let description: String
    let difficulty: Float
    let timestamp: Date
    let photoURL: URL?
    let fileURL: URL?
    
    init(
        id: UUID = UUID(),
        type: ActivityType,
        description: String,
        difficulty: Float,
        timestamp: Date = Date(),
        photoURL: URL? = nil,
        fileURL: URL? = nil
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.difficulty = difficulty
        self.timestamp = timestamp
        self.photoURL = photoURL
        self.fileURL = fileURL
    }
}
