import SwiftUI

/// Form for entering details about a completed task
/// Captures task name, emotional response, categories, and an optional photo
struct NewTaskForm: View {
    // MARK: - Required Properties
    
    /// Difficulty score received from HapticView (required parameter)
    var difficultyScore: Int
    
    // MARK: - Environment
    
    /// Access to the task store for saving tasks
    @EnvironmentObject var taskStore: TaskStore
    
    /// Used to dismiss the view when task is saved
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    
    /// Title of the task
    @State private var taskTitle = ""
    
    /// Detailed description of the task
    @State private var taskName = ""
    
    /// Date when the task was completed
    @State private var taskDate = Date()
    
    /// Location where the task was completed
    @State private var taskLocation = ""
    
    /// Tracks which emotion icon is selected (nil if none selected)
    @State private var selectedSmiley: Int? = nil
    
    /// Optional image captured from camera or photo library
    @State private var selectedImage: UIImage? = nil
    
    /// Controls whether the image picker is displayed
    @State private var showImagePicker = false
    
    /// Array of category names that have been selected
    @State private var selectedCategories: [String] = []
    
    /// Shows validation alerts
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Constants
    
    /// Icons representing different emotional responses
    let smileys = ["face.smiling", "face.smiling", "face.smiling", "face.smiling", "face.smiling"]
    
    /// Available task categories for classification
    let categories = ["Academic", "Personal", "Professional"]
    
    // MARK: - View Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Emotional response selection
                VStack(alignment: .leading) {
                    Text("How you feel:")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        ForEach(smileys.indices, id: \.self) { index in
                            Image(systemName: smileys[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(
                                    selectedSmiley == index ? Color.blue : Color.gray
                                )
                                .onTapGesture {
                                    selectedSmiley = index
                                }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Title field
                VStack(alignment: .leading) {
                    Text("Title")
                        .font(.headline)
                    TextField("Enter task title", text: $taskTitle)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                
                // Description field
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    TextField("Task details", text: $taskName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            
                // Category selection
                VStack(alignment: .leading) {
                    Text("Category:")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                Text(category)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategories.contains(category)
                                        ? Color.blue.opacity(0.2)
                                        : Color.gray.opacity(0.2)
                                    )
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        toggleCategory(category)
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Photo capture area
                VStack(alignment: .leading) {
                    Text("Photo (Optional)")
                        .font(.headline)
                    
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            Text("Take a pic!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .onTapGesture {
                        showImagePicker = true
                    }
                }
                
                // Date field
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.headline)
                    DatePicker("", selection: $taskDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Location field
                VStack(alignment: .leading) {
                    Text("Location (Optional)")
                        .font(.headline)
                    TextField("Enter location", text: $taskLocation)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Save button
                Button(action: saveTask) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("New Achievement")
        .sheet(isPresented: $showImagePicker) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            } else {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Information"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Helper Properties
    
    /// Returns a color based on the difficulty score
    private var difficultyColor: Color {
        if difficultyScore < 33 {
            return .green
        } else if difficultyScore < 67 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Methods
    
    /// Toggle a category's selection state
    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
    
    /// Save the task and dismiss the form
    private func saveTask() {
        // Validate required fields
        if taskTitle.isEmpty {
            showAlert = true
            alertMessage = "Please enter a title for your task."
            return
        }
        
        // Create new task with all the form data
        let newTask = Task(
            title: taskTitle,
            date: taskDate,
            location: taskLocation.isEmpty ? nil : taskLocation,
            difficultyScore: difficultyScore,
            emotionIndex: selectedSmiley,
            categories: selectedCategories
        )
        
        // Save task with the task store
        taskStore.saveTask(newTask, image: selectedImage)
        
        // Dismiss the form
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct NewTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewTaskForm(difficultyScore: 75)
                .environmentObject(TaskStore())
        }
    }
}
