import SwiftUI

struct ContentView: View {
    @StateObject private var activityViewModel = ActivityViewModel()
    @State private var showingActivitySheet = false
    
    var body: some View {
        TabView {
            EmotionView(viewModel: activityViewModel)  // Pass viewModel here
                .tabItem {
                    Label("Emotion", systemImage: "face.smiling")
                }
            
            CalendarView(viewModel: activityViewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .sheet(isPresented: $showingActivitySheet) {
            ActivityFormView(viewModel: activityViewModel)
        }
        .overlay(
            Button(action: {
                showingActivitySheet = true
            }) {
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
}
