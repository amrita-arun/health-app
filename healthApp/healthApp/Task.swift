import Foundation
import SwiftUI

/// Model representing a completed task or achievement
struct Task: Identifiable, Codable {
    /// Unique identifier for the task
    var id = UUID()
    
    /// Title of the task
    var title: String
    
    /// Date when the task was completed
    var date: Date
    
    /// Optional location where the task was completed
    var location: String?
    
    /// Difficulty score (0-100) assigned using haptic feedback
    var difficultyScore: Int
    
    /// Index of the selected emotional response (0-4)
    var emotionIndex: Int?
    
    /// Array of categories assigned to this task
    var categories: [String]
    
    /// Filename for the saved image (if any)
    var imageFileName: String?
}
