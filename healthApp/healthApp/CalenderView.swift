import SwiftUI
import Foundation

struct CalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel  // Add this
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    let activitiesForDay = viewModel.activitiesForDate(selectedDate)
                    if activitiesForDay.isEmpty {
                        Text("No activities for this day")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(activitiesForDay) { activity in
                            VStack(alignment: .leading) {
                                Text(activity.description)
                                    .font(.headline)
                                Text("Difficulty: \(Int(activity.difficulty * 100))%")
                                Text("Type: \(activity.type.rawValue)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
        }
    }
}
