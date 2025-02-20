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
}
