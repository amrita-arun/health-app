import SwiftUI

/// Main dashboard view for the health tracking app.
/// Displays user greeting, action buttons, calendar, and motivational quotes.
struct ContentView: View {
    // MARK: - State Variables
    
    /// Shared task store for the application
    @StateObject private var taskStore = TaskStore()
    
    /// Tracks the currently displayed month (initialized to current month)
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    
    /// Tracks the currently displayed year (initialized to current year)
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    
    /// Controls whether the achievement logging view is displayed
    @State private var showHapticView = false
    
    /// Controls whether the day detail view is displayed
    @State private var showDayDetail = false
    
    /// Stores the date when a calendar day is selected
    @State private var selectedDayDate: Date?
    
    /// The user's name for personalized greeting
    let userName = "Shruti"
    
    /// Collection of motivational quotes to display randomly
    let quotes = [
        "Believe you can and you're halfway there.",
        "Don't watch the clock; do what it does. Keep going.",
        "Act as if what you do makes a difference. It does.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts."
    ]
    
    /// Currently displayed motivational quote
    @State private var displayedQuote: String = ""
    
    /// Device color scheme detection (light/dark mode)
    @Environment(\.colorScheme) var colorScheme

    /// Computed property to determine text color based on color scheme
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: User Greeting Header
                Text("Hello, \(userName)!")
                    .font(.system(size: 30).bold())
                    .bold()
                    .foregroundColor(textColor)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                // MARK: Action Buttons
                // Horizontal scrollable action buttons with gradient backgrounds
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        let colors: [LinearGradient] = [
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.6), Color.pink.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.15)]), startPoint: .trailing, endPoint: .leading),
                            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.yellow.opacity(0.15)]), startPoint: .trailing, endPoint: .leading)
                        ]
                        
                        ForEach(0..<4) { index in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colors[index])
                                .frame(width: 160, height: 80)
                        }
                    }
                    .padding()
                }
                
                // MARK: Calendar View
                VStack {
                    // Month navigation header
                    HStack {
                        Button(action: {
                            previousMonth()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(textColor)
                        }
                        Spacer()
                        Text("\(monthName(currentMonth)) \(currentYear)")
                            .foregroundColor(textColor)
                            .font(.system(size: 20).bold())
                        Spacer()
                        Button(action: {
                            nextMonth()
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(textColor)
                        }
                    }
                    .padding()
                    
                    // Day of week headers
                    HStack {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13))
                                .foregroundColor(textColor)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar days grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        let days = generateCalendarDays()
                        let today = Calendar.current.component(.day, from: Date())
                        let currentMonthNow = Calendar.current.component(.month, from: Date())
                        let currentYearNow = Calendar.current.component(.year, from: Date())
                        
                        ForEach(days.indices, id: \.self) { index in
                            let day = days[index]
                            
                            if day > 0 {
                                let isToday = (day == today && self.currentMonth == currentMonthNow && self.currentYear == currentYearNow)
                                
                                // Create a date for this calendar day
                                let dateComponents = DateComponents(year: self.currentYear, month: self.currentMonth, day: day)
                                let dayDate = Calendar.current.date(from: dateComponents) ?? Date()
                                
                                // Check if tasks exist for this day
                                let hasTasks = taskStore.hasTasksOnDate(dayDate)
                                
                                ZStack {
                                    if isToday {
                                        Circle()
                                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    Text("\(day)")
                                        .frame(width: 40, height: 55)
                                        .background(isToday ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear)
                                        .cornerRadius(5)
                                        .foregroundColor(isToday ? (colorScheme == .dark ? Color.black : Color.white) : textColor)
                                    
                                    // Display indicator if tasks exist for this day
                                    if hasTasks {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .offset(y: 15)
                                    }
                                }
                                .contentShape(Rectangle()) // Make entire area tappable
                                .onTapGesture {
                                    selectedDayDate = dayDate
                                    showDayDetail = true
                                }
                            } else {
                                // Empty space for padding days
                                Text("")
                                    .frame(width: 40, height: 55)
                            }
                        }
                    }
                    .padding()
                }
                
                // MARK: Motivational Quote
                Text(displayedQuote)
                    .font(.custom("Helvetica", size: 16))
                    .foregroundColor(textColor)
                    .padding()
                    .onAppear { updateQuote() } // Load a random quote when view appears
                    
                Spacer()
                
                // MARK: Achievement Logging Button
                Button(action: {
                    showHapticView = true // Show the achievement logging view
                }) {
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
            .sheet(isPresented: $showHapticView) {
                HapticView()
                    .environmentObject(taskStore)
            }
            .sheet(isPresented: $showDayDetail) {
                if let date = selectedDayDate {
                    NavigationView {
                        DayDetailView(date: date, taskStore: taskStore)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Converts month number to full month name (e.g., 1 -> "January")
    func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[month - 1]
    }
    
    /// Generates an array of day numbers to display in the calendar
    /// Returns an array where 0 represents padding days and positive numbers are actual days
    func generateCalendarDays() -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        var days = [Int]()
        
        let components = DateComponents(year: currentYear, month: currentMonth)
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date),
           let firstDay = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) {
            
            // Calculate offset for the first day of month (e.g., if month starts on Wednesday, offset = 3)
            let weekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday, 7 = Saturday
            let offset = (weekday - 1) % 7
            
            // Add padding days and actual days to the array
            days.append(contentsOf: Array(repeating: 0, count: offset))
            days.append(contentsOf: range) // Actual days of the month
        }
        return days
    }
    
    /// Navigate to the previous month, handling year transition if needed
    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    /// Navigate to the next month, handling year transition if needed
    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    /// Select and display a random motivational quote
    func updateQuote() {
        displayedQuote = quotes.randomElement() ?? "Stay positive!"
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskStore())
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
