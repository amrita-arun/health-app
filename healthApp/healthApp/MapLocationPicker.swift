//
//  MapLocationPicker.swift
//  healthApp
//

import SwiftUI
import MapKit

// MARK: - Map Location Picker View
/// Allows users to select a location by dropping a pin on a map
struct MapLocationPicker: View {
    // MARK: Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Binding Properties
    /// Binding to update location name in parent view
    @Binding var locationName: String
    /// Binding to update location coordinates in parent view
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    // MARK: State Properties
    /// The current region shown on the map
    @State private var region: MKCoordinateRegion
    /// The current pin position
    @State private var pinLocation: CLLocationCoordinate2D?
    /// Whether we're currently processing a pin drop
    @State private var isProcessingLocation = false
    /// Zoom level (0-20, where 20 is closest)
    @State private var zoomLevel: Double = 15
    
    // MARK: Initialization
    
    /// Initialize with user's current location if available
    init(locationName: Binding<String>, selectedCoordinate: Binding<CLLocationCoordinate2D?>, userLocation: CLLocationCoordinate2D? = nil) {
        self._locationName = locationName
        self._selectedCoordinate = selectedCoordinate
        
        // Set initial region (either user location or default)
        if let userLocation = userLocation {
            _region = State(initialValue: MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            _pinLocation = State(initialValue: userLocation)
        } else {
            // Default to San Francisco if no location available
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pinItems()) { item in
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { tapLocation in
                    // Note: This uses the center of the tap rather than the exact location
                    // For more precise location, a UIViewRepresentable with MKMapView would be needed
                    dropPin(at: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2))
                }
                
                // Zoom Controls Overlay (right side)
                VStack {
                    Spacer()
                    
                    // Zoom controls
                    VStack(spacing: 8) {
                        // Zoom in button
                        Button(action: {
                            zoomIn()
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        
                        // Zoom slider (vertical)
                        Slider(value: $zoomLevel, in: 1...20, step: 0.5)
                            .frame(height: 120)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 40, height: 120)
                            .onChange(of: zoomLevel) { newValue in
                                updateZoom()
                            }
                        
                        // Zoom out button
                        Button(action: {
                            zoomOut()
                        }) {
                            Image(systemName: "minus")
                                .font(.title2)
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.bottom, 100)
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                
                // Center Crosshair (optional)
                if pinLocation == nil {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .opacity(0.7)
                        )
                }
                
                // Loading Indicator
                if isProcessingLocation {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                }
                
                // Instructions
                VStack {
                    Text("Tap anywhere on the map to drop a pin")
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 50)
                    
                    Spacer()
                }
            }
            .navigationTitle("Select Location")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use This Location") {
                        if let pinLocation = pinLocation {
                            selectedCoordinate = pinLocation
                            dismiss()
                        }
                    }
                    .disabled(pinLocation == nil)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Create annotation items for the map
    private func pinItems() -> [MapAnnotationItem] {
        guard let pinLocation = pinLocation else { return [] }
        return [MapAnnotationItem(coordinate: pinLocation)]
    }
    
    /// Handle map tap for pin dropping
    private func dropPin(at tapLocation: CGPoint) {
        // Convert screen point to map coordinate
        let mapCoordinate = convertPointToCoordinate(tapLocation)
        pinLocation = mapCoordinate
        
        // Update the region to center on the new pin
        region = MKCoordinateRegion(
            center: mapCoordinate,
            span: region.span
        )
        
        // Reverse geocode to get location name
        isProcessingLocation = true
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isProcessingLocation = false
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                locationName = "Unknown Location"
                return
            }
            
            if let placemark = placemarks?.first {
                // Format address from placemark
                var addressComponents: [String] = []
                
                if let name = placemark.name { addressComponents.append(name) }
                if let thoroughfare = placemark.thoroughfare { addressComponents.append(thoroughfare) }
                if let locality = placemark.locality { addressComponents.append(locality) }
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }
                
                // Set location name
                locationName = addressComponents.isEmpty ? "Unknown Location" : addressComponents.joined(separator: ", ")
            } else {
                locationName = "Unknown Location"
            }
        }
    }
    
    /// Convert a screen point to a map coordinate
    private func convertPointToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D {
        // This is a simplified approximation - actual implementation would use MKMapView methods
        // For SwiftUI Map, we estimate based on the current region
        
        // Get the frame size (estimate for this example)
        let width: CGFloat = UIScreen.main.bounds.width
        let height: CGFloat = UIScreen.main.bounds.height
        
        // Calculate position ratios (0 to 1)
        let xRatio = point.x / width
        let yRatio = point.y / height
        
        // Convert to coordinate offsets
        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta
        
        let latOffset = latitudeDelta * (0.5 - yRatio)
        let lonOffset = longitudeDelta * (xRatio - 0.5)
        
        // Apply offsets to center coordinate
        return CLLocationCoordinate2D(
            latitude: region.center.latitude + latOffset,
            longitude: region.center.longitude + lonOffset
        )
    }
    
    // MARK: - Zoom Functions
    
    /// Zoom in on the map (decrease span)
    private func zoomIn() {
        zoomLevel = min(20, zoomLevel + 1)
        updateZoom()
    }
    
    /// Zoom out on the map (increase span)
    private func zoomOut() {
        zoomLevel = max(1, zoomLevel - 1)
        updateZoom()
    }
    
    /// Update the map region based on zoom level
    private func updateZoom() {
        // Convert zoom level (1-20) to span delta (smaller number = closer zoom)
        // Exponential scaling provides more natural zooming feel
        let scaleFactor = pow(2, 20 - zoomLevel) / 1000
        
        // Update region with new span while keeping the center point
        region = MKCoordinateRegion(
            center: region.center,
            span: MKCoordinateSpan(
                latitudeDelta: scaleFactor,
                longitudeDelta: scaleFactor
            )
        )
    }
}

// MARK: - Map Annotation Item
/// Simple model for map annotations
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Preview
struct MapLocationPicker_Previews: PreviewProvider {
    static var previews: some View {
        MapLocationPicker(
            locationName: .constant("Sample Location"),
            selectedCoordinate: .constant(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        )
    }
}
