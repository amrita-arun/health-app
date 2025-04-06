import SwiftUI

/// View for displaying all tasks completed on a specific day
struct DayDetailView: View {
    /// The date for which tasks are being displayed
    let date: Date
    
    /// Access to the task store for retrieving tasks
    @ObservedObject var taskStore: TaskStore
    
    /// Formatter for date display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    var body: some View {
        VStack {
            Text(dateFormatter.string(from: date))
                .font(.headline)
                .padding()
            
            let dayTasks = taskStore.tasksForDate(date)
            
            if dayTasks.isEmpty {
                Spacer()
                Text("No tasks completed on this day")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(dayTasks) { task in
                        TaskRow(task: task, taskStore: taskStore)
                    }
                }
            }
        }
        .navigationTitle("Daily Achievements")
    }
}

/// Row displaying a single task
struct TaskRow: View {
    let task: Task
    let taskStore: TaskStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(.headline)
            
            if !task.categories.isEmpty {
                HStack {
                    ForEach(task.categories, id: \.self) { category in
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            HStack {
                Text("Difficulty: \(task.difficultyScore)")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor(score: task.difficultyScore).opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if let location = task.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if let fileName = task.imageFileName, let image = taskStore.loadImage(fileName: fileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
    
    /// Return color based on difficulty score
    private func difficultyColor(score: Int) -> Color {
        if score < 33 {
            return .green
        } else if score < 67 {
            return .orange
        } else {
            return .red
        }
    }
}
