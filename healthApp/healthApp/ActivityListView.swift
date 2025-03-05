//
//  ActivityListView.swift
//  healthApp
//

import SwiftUI

// MARK: - Activity List View
/// Displays activities for a selected date
struct ActivityListView: View {
    // MARK: Environment
    
    /// Dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    /// Color scheme (light/dark mode)
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Properties
    
    /// View model containing activities data
    @ObservedObject var viewModel: ActivityViewModel
    
    // MARK: Computed Properties
    
    /// Date formatter for display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    /// Text color based on color scheme
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.activitiesForSelectedDate.isEmpty {
                    // MARK: Empty State
                    VStack {
                        Spacer()
                        
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No activities for this date")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                } else {
                    // MARK: Activity List
                    List {
                        ForEach(viewModel.activitiesForSelectedDate) { activity in
                            ActivityRow(activity: activity)
                                .listRowBackground(colorScheme == .dark ? Color.black : Color.white)
                        }
                        .onDelete { indexSet in
                            // Delete activities at the specified indices
                            for index in indexSet {
                                let activityID = viewModel.activitiesForSelectedDate[index].id
                                viewModel.deleteActivity(withID: activityID)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(dateFormatter.string(from: viewModel.selectedDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Activity Row
/// Row displaying a single activity in the list
struct ActivityRow: View {
    // MARK: Properties
    
    /// The activity to display
    let activity: Activity
    
    // MARK: Computed Properties
    
    /// Color based on activity difficulty
    private var difficultyColor: Color {
        switch activity.difficulty {
        case 0..<30:
            return .green
        case 30..<70:
            return .orange
        default:
            return .red
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: Activity Name and Type
            HStack {
                Text(activity.name)
                    .font(.headline)
                
                Spacer()
                
                Text(activity.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // MARK: Difficulty Level
            HStack {
                Text("Difficulty:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(activity.difficulty)")
                    .font(.caption)
                    .foregroundColor(difficultyColor)
                
                // Visual difficulty meter
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: 100, height: 6)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: CGFloat(activity.difficulty), height: 6)
                        .foregroundColor(difficultyColor)
                        .cornerRadius(3)
                }
            }
            
            // MARK: Location
            if !activity.locationName.isEmpty {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(activity.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: Description (if present)
            if !activity.description.isEmpty {
                Text(activity.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a view model in preview mode
        let viewModel = ActivityViewModel(isPreview: true)
        
        // Add sample activities for preview
        let sampleActivity1 = Activity(
            name: "Morning Run",
            type: .cardio,
            description: "5 mile run through the park",
            difficulty: 65,
            locationName: "Central Park",
            latitude: 40.7812,
            longitude: -73.9665
        )
        
        let sampleActivity2 = Activity(
            name: "Yoga Session",
            type: .flexibility,
            description: "30 minute yoga routine",
            difficulty: 35,
            locationName: "Home",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        viewModel.addActivity(sampleActivity1)
        viewModel.addActivity(sampleActivity2)
        viewModel.selectedDate = Date()
        
        return ActivityListView(viewModel: viewModel)
    }
}
