<<<<<<< Updated upstream
import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    
    func addActivity(type: ActivityType, description: String, difficulty: Float) {
        let activity = Activity(
            type: type,
            description: description,
            difficulty: difficulty
        )
        activities.append(activity)
        saveActivities()
    }
    
    func activitiesForDate(_ date: Date) -> [Activity] {
        activities.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: "SavedActivities")
        }
    }
    
    private func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: "SavedActivities"),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        }
    }
    
    init() {
        loadActivities()
    }
=======
//
//  ActivityViewModel.swift
//  healthApp
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

// MARK: - Activity View Model
/// Manages activity data storage, retrieval, and business logic
class ActivityViewModel: ObservableObject {
    // MARK: Published Properties
    
    private let isPreview: Bool
        
        // MARK: Published Properties
        @Published var activities: [Activity] = []
        @Published var activitiesForSelectedDate: [Activity] = []
        @Published var selectedDate: Date = Date() {
            didSet {
                filterActivitiesForSelectedDate()
            }
        }
        
        // MARK: Private Properties
        private let activitiesKey = "userActivities"
        
        // MARK: Initialization
        
        // Add a parameter to specify if this is for preview
        init(isPreview: Bool = false) {
            self.isPreview = isPreview
            
            // Only load saved activities if not in preview mode
            if !isPreview {
                loadActivities()
            }
        }
        
        // MARK: Activity Management Methods
        
        func addActivity(_ activity: Activity) {
            activities.append(activity)
            
            if Calendar.current.isDate(activity.date, inSameDayAs: selectedDate) {
                activitiesForSelectedDate.append(activity)
            }
            
            // Only save to persistent storage if not in preview mode
            if !isPreview {
                saveActivities()
            }
        }
        
        func deleteActivity(withID id: UUID) {
            activities.removeAll { $0.id == id }
            activitiesForSelectedDate.removeAll { $0.id == id }
            
            // Only save to persistent storage if not in preview mode
            if !isPreview {
                saveActivities()
            }
        }
        
        func updateActivity(_ updatedActivity: Activity) {
            if let index = activities.firstIndex(where: { $0.id == updatedActivity.id }) {
                activities[index] = updatedActivity
            }
            
            if let filteredIndex = activitiesForSelectedDate.firstIndex(where: { $0.id == updatedActivity.id }) {
                activitiesForSelectedDate[filteredIndex] = updatedActivity
            }
            
            // Only save to persistent storage if not in preview mode
            if !isPreview {
                saveActivities()
            }
        }
    
    func clearAllActivities() {
        activities = []
        activitiesForSelectedDate = []
        UserDefaults.standard.removeObject(forKey: activitiesKey)
    }
    
    /// Check if a date has any activities
    func hasActivities(for date: Date) -> Bool {
        return activities.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Get activity count for a specific date
    func activityCount(for date: Date) -> Int {
        return activities.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.count
    }
    
    /// Filter activities for the currently selected date
    private func filterActivitiesForSelectedDate() {
        activitiesForSelectedDate = activities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    // MARK: Persistence Methods
    
    /// Save activities to UserDefaults
    private func saveActivities() {
        do {
            // Encode activities to JSON data
            let encoder = JSONEncoder()
            let data = try encoder.encode(activities)
            
            // Store in UserDefaults
            UserDefaults.standard.set(data, forKey: activitiesKey)
        } catch {
            print("Failed to save activities: \(error.localizedDescription)")
        }
    }
    
    /// Load activities from UserDefaults
    private func loadActivities() {
        // Check if we have saved data
        if let data = UserDefaults.standard.data(forKey: activitiesKey) {
            do {
                // Decode JSON data to activities array
                let decoder = JSONDecoder()
                activities = try decoder.decode([Activity].self, from: data)
                
                // Initial filtering for selected date
                filterActivitiesForSelectedDate()
            } catch {
                print("Failed to load activities: \(error.localizedDescription)")
                // Start with an empty collection if loading fails
                activities = []
                activitiesForSelectedDate = []
            }
        }
    }
>>>>>>> Stashed changes
}
