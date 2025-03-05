//
//  ActivityLogView.swift
//  healthApp
//

import SwiftUI
import CoreLocation
import MapKit

// MARK: - Activity Log View
/// Form for entering activity details after haptic feedback
struct ActivityLogView: View {
    // MARK: Environment Objects
    
    /// Dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    /// Activity view model to save the new activity
    @ObservedObject var viewModel: ActivityViewModel
    
    // MARK: State Properties
    
    /// Activity details being edited
    @State private var activityName: String = ""
    @State private var selectedType: ActivityType = .cardio
    @State private var activityDescription: String = ""
    @State private var locationName: String = ""
    
    /// Location manager for current location
    @StateObject private var locationManager = LocationManager()
    
    /// Show location picker sheet
    @State private var showingLocationPicker = false
    
    /// Custom location if user chooses a different location
    @State private var customLocation: CLLocationCoordinate2D?
    
    /// Form validation
    @State private var showValidationAlert = false
    
    // MARK: Binding Properties
    
    /// Binding to control the HapticView's presentation
    @Binding var hapticViewPresented: Bool
    
    // MARK: Initialization Properties
    
    /// The difficulty score from the haptic view
    let difficultyScore: Int
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // MARK: Basic Information Section
                Section(header: Text("Activity Details")) {
                    // Name field
                    TextField("Activity Name", text: $activityName)
                    #if os(iOS)
                    .autocapitalization(.words)
                    #endif
                    
                    // Type picker
                    Picker("Activity Type", selection: $selectedType) {
                        ForEach(ActivityType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    // Description field
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $activityDescription)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                // MARK: Difficulty Section
                Section(header: Text("Difficulty")) {
                    // Display the difficulty from the haptic view
                    HStack {
                        Text("Difficulty Level")
                        Spacer()
                        Text("\(difficultyScore)")
                            .bold()
                            .foregroundColor(difficultyColorFor(score: difficultyScore))
                    }
                    
                    // Visual representation of difficulty
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: CGFloat(difficultyScore) * 3, height: 8)
                            .foregroundColor(difficultyColorFor(score: difficultyScore))
                            .cornerRadius(4)
                    }
                }
                
                // MARK: Location Section
                Section(header: Text("Location")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Show either the detected location or custom location
                            if customLocation != nil {
                                Text(locationName)
                            } else {
                                Text(locationManager.locationName)
                            }
                        }
                        
                        Spacer()
                        
                        // Change location button
                        Button("Change") {
                            showingLocationPicker = true
                        }
                    }
                }
            }
            .navigationTitle("Log Activity")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        hapticViewPresented = false  // Close both views
                        dismiss()
                    }
                }
                
                // Save button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveActivity()
                    }
                }
            }
            .sheet(isPresented: $showingLocationPicker) {
                MapLocationPicker(
                    locationName: $locationName,
                    selectedCoordinate: $customLocation,
                    userLocation: locationManager.location?.coordinate
                )
                .edgesIgnoringSafeArea(.all)
            }
            .alert("Missing Information", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please provide an activity name.")
            }
            .onAppear {
                // Initialize location name when the view appears
                if locationManager.locationName != "Loading location..." {
                    locationName = locationManager.locationName
                }
            }
        }
    }
    
    // MARK: Helper Methods
    
    /// Save the activity and return to the main view
    private func saveActivity() {
        // Validate required fields
        guard !activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationAlert = true
            return
        }
        
        // Create the activity with appropriate location data
        let activity: Activity
        
        if let customLocation = customLocation {
            // User selected a custom location
            activity = Activity(
                name: activityName,
                type: selectedType,
                description: activityDescription,
                difficulty: difficultyScore,
                locationName: locationName,
                latitude: customLocation.latitude,
                longitude: customLocation.longitude
            )
        } else if let currentLocation = locationManager.location {
            // Use the current device location
            activity = Activity(
                name: activityName,
                type: selectedType,
                description: activityDescription,
                difficulty: difficultyScore,
                locationName: locationManager.locationName,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
        } else {
            // Fallback if location services are unavailable
            activity = Activity(
                name: activityName,
                type: selectedType,
                description: activityDescription,
                difficulty: difficultyScore,
                locationName: "Unknown Location",
                latitude: 0,
                longitude: 0
            )
        }
        
        // Save to view model and dismiss
        viewModel.addActivity(activity)
        
        // Close both views
        hapticViewPresented = false
        dismiss()
    }
    
    /// Return appropriate color based on difficulty score
    private func difficultyColorFor(score: Int) -> Color {
        switch score {
        case 0..<30:
            return .green
        case 30..<70:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Preview
struct ActivityLogView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityLogView(
            viewModel: ActivityViewModel(isPreview: true),
            hapticViewPresented: .constant(true),  // Moved before difficultyScore
            difficultyScore: 75
        )
    }
}
