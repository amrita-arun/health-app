//
//  ActivityModel.swift
//  healthApp
//

import Foundation
import CoreLocation

// MARK: - Activity Types
/// Enum to categorize different types of activities
enum ActivityType: String, CaseIterable, Identifiable, Codable {
    // Activity categories
    case cardio = "Cardio"
    case strength = "Strength Training"
    case flexibility = "Flexibility"
    case mindfulness = "Mindfulness"
    case sports = "Sports"
    case other = "Other"
    
    // Conformance to Identifiable protocol
    var id: String { self.rawValue }
}

// MARK: - Activity Model
/// Data structure representing a user's activity
struct Activity: Identifiable, Codable {
    // Unique identifier for the activity
    var id = UUID()
    
    // Core activity information
    var name: String                // Name of the activity
    var type: ActivityType          // Category of the activity
    var description: String         // Detailed description
    var difficulty: Int             // Difficulty level (0-100)
    
    // Location information
    var locationName: String        // Human-readable location name
    var latitude: Double            // Geographic coordinates
    var longitude: Double
    
    // Timestamp
    var date: Date                  // When the activity occurred
    
    // MARK: Location Convenience Methods
    
    /// Convert to CLLocation object for mapping functionality
    func getCoordinateLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Initialization
    
    /// Create a new activity with full details
    init(id: UUID = UUID(), name: String, type: ActivityType, description: String, difficulty: Int,
             locationName: String, latitude: Double, longitude: Double, date: Date = Date()) {
            self.id = id
            self.name = name
            self.type = type
            self.description = description
            self.difficulty = difficulty
            self.locationName = locationName
            self.latitude = latitude
            self.longitude = longitude
            self.date = date
        }
    
    /// Create a simple activity with default location
    init(name: String, type: ActivityType, difficulty: Int) {
        self.name = name
        self.type = type
        self.description = ""
        self.difficulty = difficulty
        self.locationName = "Unknown Location"
        self.latitude = 0.0
        self.longitude = 0.0
        self.date = Date()
    }
}

// MARK: - Date Extensions
extension Date {
    /// Format date as a string with custom format
    func formatted(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Check if date is the same day as another date
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}
