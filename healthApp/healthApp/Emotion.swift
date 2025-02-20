import Foundation
import SwiftUI // Add this for UUID if needed

struct Emotion: Codable, Identifiable {
    let id: UUID
    let emoji: String
    let timestamp: Date
    
    init(id: UUID = UUID(), emoji: String, timestamp: Date = Date()) {
        self.id = id
        self.emoji = emoji
        self.timestamp = timestamp
    }
    
    // Add Codable conformance explicitly if needed
    enum CodingKeys: String, CodingKey {
        case id
        case emoji
        case timestamp
    }
}
