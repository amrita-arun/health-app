import SwiftUI

//testing whether I am commiting to the right remote repo
struct EmotionView: View {
    @ObservedObject var viewModel: ActivityViewModel  // Add this
    @State private var showingActivitySheet = false
    @State private var selectedEmoji: String?
    
    let emojis = ["😊", "😢", "😡", "😴", "😃", "😔"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How are you feeling?")
                    .font(.title)
                    .padding()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 60))
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .sheet(isPresented: $showingActivitySheet) {
                ActivityFormView(viewModel: viewModel)  // Pass viewModel here too
            }
        }
    }
}

#Preview {
    EmotionView(viewModel: ActivityViewModel())
}
