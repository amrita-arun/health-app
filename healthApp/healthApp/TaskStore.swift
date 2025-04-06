import SwiftUI
import Combine

/// Service to manage storage and retrieval of tasks
class TaskStore: ObservableObject {
    /// Published collection of all saved tasks
    @Published var tasks: [Task] = []
    
    /// Directory URL for saving images
    private let imagesDirectory: URL
    
    /// File URL for persisting tasks
    private let tasksURL: URL
    
    init() {
        // Setup file URLs
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsDirectory.appendingPathComponent("taskImages")
        tasksURL = documentsDirectory.appendingPathComponent("tasks.json")
        
        // Create images directory if needed
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        
        // Load saved tasks
        loadTasks()
    }
    
    /// Save a task with optional image
    func saveTask(_ task: Task, image: UIImage? = nil) {
        var updatedTask = task
        
        // Save image if provided
        if let image = image {
            let fileName = "\(task.id.uuidString).jpg"
            updatedTask.imageFileName = fileName
            saveImage(image, withName: fileName)
        }
        
        // Add task to collection
        tasks.append(updatedTask)
        saveTasks()
    }
    
    /// Check if tasks exist for a specific date
    func hasTasksOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return tasks.contains { task in
            calendar.isDate(task.date, inSameDayAs: date)
        }
    }
    
    /// Get all tasks for a specific date
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.date, inSameDayAs: date)
        }
    }
    
    /// Load saved image by filename
    func loadImage(fileName: String) -> UIImage? {
        guard let imageData = try? Data(contentsOf: imagesDirectory.appendingPathComponent(fileName)) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    /// Save image to filesystem
    private func saveImage(_ image: UIImage, withName fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: fileURL)
        }
    }
    
    /// Save all tasks to persistent storage
    private func saveTasks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tasks)
            try data.write(to: tasksURL)
        } catch {
            print("Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    /// Load tasks from persistent storage
    private func loadTasks() {
        guard FileManager.default.fileExists(atPath: tasksURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: tasksURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            tasks = try decoder.decode([Task].self, from: data)
        } catch {
            print("Failed to load tasks: \(error.localizedDescription)")
        }
    }
}
