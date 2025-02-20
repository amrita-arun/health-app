import SwiftUI

struct ActivityFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    
    @State private var difficulty: Float = 0.5
    @State private var selectedType: ActivityType = .personal
    @State private var description = ""
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Difficulty") {
                    Slider(value: $difficulty) {
                        Text("Difficulty")
                    }
                }
                
                Section("Type") {
                    Picker("Activity Type", selection: $selectedType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Add Photo") {
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle("New Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addActivity(
                            type: selectedType,
                            description: description,
                            difficulty: difficulty
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ActivityFormView(viewModel: ActivityViewModel())
}
