//
//  NewTaskForm.swift
//  healthApp
//
//  Created by Administrator on 3/5/25.
//

import SwiftUI

struct NewTaskForm: View {
    // You can use a state variable to track which smiley is selected
        @State private var selectedSmiley: Int? = nil

        @State var taskName = ""
    
        @State private var selectedImage: UIImage? = nil
        // State for presenting the camera
        @State private var showImagePicker = false
        
        // You can also use a state variable to track selected categories
        @State private var selectedCategories: [String] = []
        
        let smileys = ["face.smiling", "face.smiling", "face.smiling", "face.smiling", "face.smiling"]
        let categories = ["Academic", "Personal", "Professional"]
        
        var body: some View {
            VStack(spacing: 30) {
                
                // Task Completed Label
                TextField("Task Completed", text: $taskName)
                    .multilineTextAlignment(.leading)
                
                // How You Feel + Smiley Icons
                VStack(spacing: 10) {
                    Text("How you feel:")
                        .font(.subheadline)
                    
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
                }
                
                // Category Chips
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category:")
                        .font(.headline)
        
                        
                    
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
                                    if selectedCategories.contains(category) {
                                        // Remove if already selected
                                        selectedCategories.removeAll { $0 == category }
                                    } else {
                                        // Add if not selected
                                        selectedCategories.append(category)
                                    }
                                }
                        }
                    }
                }
                
                // "Take a pic!" placeholder
                        ZStack {
                            // If an image is selected, show it; otherwise, show placeholder text
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            } else {
                                Text("Take a pic!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .onTapGesture {
                            // Show camera
                            showImagePicker = true
                        }
                        
                        // Done Button
                        Button(action: {
                            // Handle button action
                        }) {
                            Text("Done")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    // Present the ImagePicker as a sheet
                    .sheet(isPresented: $showImagePicker) {
                        // IMPORTANT: Check if camera is available to avoid simulator issues
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                        } else {
                            // Fallback to photo library if camera is not available
                            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                        }
                    }
            }
}

struct NewTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskForm()
    }
}
