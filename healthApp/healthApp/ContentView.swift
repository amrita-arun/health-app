import SwiftUI

struct ContentView: View {
<<<<<<< Updated upstream
    @StateObject private var activityViewModel = ActivityViewModel()
    @State private var showingActivitySheet = false
=======
    // MARK: - State Management
    // Track the current month and year for the calendar display
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    // Controls the presentation of the HapticView modal
    @State private var showHapticView = false
    // Controls presentation of activity details for a selected date
    @State private var showActivitiesForDate = false
    
    // MARK: - View Model
    // Activity view model manages activity data
    @StateObject private var activityViewModel = ActivityViewModel(isPreview: false)
    
    // MARK: - Data Properties
    // User's name displayed in greeting
    let userName = "Shruti"
    // Collection of motivational quotes that will be randomly displayed
    let quotes = [
        "Believe you can and you're halfway there.",
        "Don't watch the clock; do what it does. Keep going.",
        "Act as if what you do makes a difference. It does.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts."
    ]
    
    // Currently displayed motivational quote
    @State private var displayedQuote: String = ""
    
    // MARK: - Environment
    // Access the current color scheme (light/dark mode)
    @Environment(\.colorScheme) var colorScheme

    // Computed property that determines text color based on dark/light mode
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
>>>>>>> Stashed changes
    
    // MARK: - UI Layout
    var body: some View {
<<<<<<< Updated upstream
        TabView {
            EmotionView(viewModel: activityViewModel)  // Pass viewModel here
                .tabItem {
                    Label("Emotion", systemImage: "face.smiling")
=======
        VStack {
            // MARK: User Greeting
            // Displays personalized greeting with user's name
            Text("Hello, \(userName)!")
                .font(.system(size: 30).bold())
                .bold()
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
            // MARK: Activity Summary
            // Horizontal scrollable row showing activity statistics
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Create gradient colors for the summary cards
                    let colors: [LinearGradient] = [
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                        LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.6), Color.pink.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                        LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                        LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.yellow.opacity(0.15)]), startPoint: .trailing, endPoint: .leading)
                    ]
                    
                    // Activity summary cards
                    let summaries = [
                        "Today's Activities: \(activityViewModel.activityCount(for: Date()))",
                        "Total Activities: \(activityViewModel.activities.count)",
                        "This Month: \(activityViewModel.activities.filter { Calendar.current.component(.month, from: $0.date) == currentMonth }.count)",
                        "Average Difficulty: \(averageDifficulty())"
                    ]
                    
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colors[index])
                            .frame(width: 160, height: 80)
                            .overlay(
                                Text(summaries[index])
                                    .foregroundColor(textColor)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            )
                    }
>>>>>>> Stashed changes
                }
            
<<<<<<< Updated upstream
            CalendarView(viewModel: activityViewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .sheet(isPresented: $showingActivitySheet) {
            ActivityFormView(viewModel: activityViewModel)
        }
        .overlay(
=======
            // MARK: Calendar View
            VStack {
                // Calendar header with month/year display and navigation buttons
                HStack {
                    // Previous month button
                    Button(action: {
                        previousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(textColor)
                    }
                    Spacer()
                    // Current month and year display
                    Text("\(monthName(currentMonth)) \(currentYear)")
                        .foregroundColor(textColor)
                        .font(.system(size: 20).bold())
                    Spacer()
                    // Next month button
                    Button(action: {
                        nextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(textColor)
                    }
                }
                .padding()
                
                // Day of week header row (Sun-Sat)
                HStack {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 13))
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // MARK: Calendar Grid
                // Display of days in a month as a grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    let days = generateCalendarDays()
                    let today = Calendar.current.component(.day, from: Date())
                    let thisMonth = Calendar.current.component(.month, from: Date())
                    let thisYear = Calendar.current.component(.year, from: Date())
                    
                    // Create cells for each day in the month
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if day > 0 {
                            // Check if this day is today for special highlighting
                            let isToday = (day == today && self.currentMonth == thisMonth && self.currentYear == thisYear)
                            
                            // Check if this day has activities
                            let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: day)
                            let date = Calendar.current.date(from: dateComponents) ?? Date()
                            let hasActivities = activityViewModel.hasActivities(for: date)
                            
                            // Day cell with activity indicator
                            Button(action: {
                                // Only show activity detail if there are activities
                                if hasActivities {
                                    activityViewModel.selectedDate = date
                                    showActivitiesForDate = true
                                }
                            }) {
                                ZStack {
                                    // Circle outline for today's date
                                    if isToday {
                                        Circle()
                                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    // Day number display
                                    Text("\(day)")
                                        .frame(width: 40, height: 40)
                                        .background(isToday ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear)
                                        .cornerRadius(5)
                                        .foregroundColor(isToday ? (colorScheme == .dark ? Color.black : Color.white) : textColor)
                                    
                                    // Activity indicator dot
                                    if hasActivities {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: 8, height: 8)
                                            .offset(y: 15)
                                    }
                                }
                            }
                        } else {
                            // Empty cell for placeholder days
                            Text("")
                                .frame(width: 40, height: 55)
                        }
                    }
                }
                .padding()
            }
            
            // MARK: Motivational Quote
            // Displays a random motivational quote
            Text(displayedQuote)
                .font(.custom("Helvetica", size: 16))
                .foregroundColor(textColor)
                .padding()
                .onAppear { updateQuote() } // Set a random quote when view appears
                
            Spacer()
            
            // MARK: Add Activity Button
            // Floating action button to open the haptic feedback view
>>>>>>> Stashed changes
            Button(action: {
                showingActivitySheet = true
            }) {
<<<<<<< Updated upstream
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding()
            ,alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
=======
                Circle()
                    .fill(colorScheme == .dark ? Color.white : Color.black)
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: "plus")
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .font(.title))
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Present the HapticView as a sheet when showHapticView is true
        .sheet(isPresented: $showHapticView) {
            HapticView(isPresented: $showHapticView)
                .environmentObject(activityViewModel)  // Pass view model to HapticView
        }
        // Present activity list for a selected date
        .sheet(isPresented: $showActivitiesForDate) {
            ActivityListView(viewModel: activityViewModel)
        }
        .onAppear {
//             Uncomment this line to clear all activities, then comment it out again
             
            
            updateQuote()
        }
    }
    
    // MARK: - Helper Functions
    
    // Convert month number to month name
    func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[month - 1]
    }
    
    // Generate array of day numbers for calendar display
    func generateCalendarDays() -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        var days = [Int]()
        
        let components = DateComponents(year: currentYear, month: currentMonth)
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date),
           let firstDay = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) {
            
            // Calculate offset for the first day of month
            let weekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday, 7 = Saturday
            let offset = (weekday - 1) % 7
            
            // Add placeholder zeros for days before the 1st of the month
            days.append(contentsOf: Array(repeating: 0, count: offset))
            // Add actual days of the month
            days.append(contentsOf: range)
        }
        return days
    }
    
    // Navigate to previous month
    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    // Navigate to next month
    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    // Select a random quote to display
    func updateQuote() {
        displayedQuote = quotes.randomElement() ?? "Stay positive!"
    }
    
    // Calculate average difficulty of all activities
    func averageDifficulty() -> String {
        let activities = activityViewModel.activities
        if activities.isEmpty {
            return "N/A"
        }
        
        let sum = activities.reduce(0) { $0 + $1.difficulty }
        let average = Double(sum) / Double(activities.count)
        return String(format: "%.1f", average)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ActivityViewModel(isPreview: true))
            .previewDevice("iPhone 13")
    }
>>>>>>> Stashed changes
}
