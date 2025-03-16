import SwiftUI

struct ContentView: View {
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    @State private var showHapticView = false  // state variable to control HapticView
    
    let userName = "Shruti"
    let quotes = [
        "Believe you can and you're halfway there.",
        "Don't watch the clock; do what it does. Keep going.",
        "Act as if what you do makes a difference. It does.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts."
    ]
    
    @State private var displayedQuote: String = ""
    
    @Environment(\.colorScheme) var colorScheme // get the current color scheme

    private var textColor: Color {
        // Change text color based on the color scheme
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        VStack {
            Text("Hello, \(userName)!")
                .font(.system(size: 30).bold())
                .bold()
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
            // button placeholders
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
            
            // cal view
            VStack {
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
                
                HStack {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 13))
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // cal grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    let days = generateCalendarDays()
                    let today = Calendar.current.component(.day, from: Date())
                    let currentMonth = Calendar.current.component(.month, from: Date())
                    let currentYear = Calendar.current.component(.year, from: Date())
                    
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        let isToday = (day == today && self.currentMonth == currentMonth && self.currentYear == currentYear)
                        
                        ZStack {
                            if isToday {
                                Circle()
                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                                    .frame(width: 40, height: 40)
                            }
                            Text(day > 0 ? "\(day)" : "")
                                .frame(width: 40, height: 55)
                                .background(isToday ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear)
                                .cornerRadius(5)
                                .foregroundColor(isToday ? (colorScheme == .dark ? Color.black : Color.white) : textColor)
                        }
                    }
                }
                .padding()
            }
            
            Text(displayedQuote)
                .font(.custom("Helvetica", size: 16))
                .foregroundColor(textColor)
                .padding()
                .onAppear { updateQuote() }
                
            Spacer()
            
            Button(action: {
                showHapticView = true
            }) {
                Circle()
                    .fill(colorScheme == .dark ? Color.white : Color.black) // Background color for light/dark mode
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: "plus")
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white) // Icon color based on mode
                        .font(.title))
            }
            .padding(.bottom, 20)
        }
        //.background(.edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showHapticView) {
            HapticView()
        }
    }
    
    func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[month - 1]
    }
    
    func generateCalendarDays() -> [Int] {
        let calendar = Calendar(identifier: .gregorian)
        var days = [Int]()
        
        let components = DateComponents(year: currentYear, month: currentMonth)
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date),
           let firstDay = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) {
            
            let weekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday, 7 = Saturday
            let offset = (weekday - 1) % 7
            
            days.append(contentsOf: Array(repeating: 0, count: offset))
            days.append(contentsOf: range) // Actual days of the month
        }
        return days
    }
    
    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    func updateQuote() {
        displayedQuote = quotes.randomElement() ?? "Stay positive!"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
                .preferredColorScheme(.dark) // change between light and dark
                //.environment(\.colorScheme, .light)
    }
}
