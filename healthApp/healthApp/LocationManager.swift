//
//  LocationManager.swift
//  healthApp
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Location Manager
/// Manages device location services and provides user's current location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: Properties
    
    /// The Core Location manager instance
    private let locationManager = CLLocationManager()
    
    /// Published properties that trigger UI updates when changed
    @Published var location: CLLocation? // Current user location
    @Published var locationName: String = "Loading location..." // Human-readable location name
    @Published var authorizationStatus: CLAuthorizationStatus // Current permission status
    
    // MARK: Initialization
    
    /// Set up the location manager and request authorization
    override init() {
        // Initialize with current authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        // Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update when user moves 10 meters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    /// Called when location permissions change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // If authorized, start location updates
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Called when new locations are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Store most recent location
        location = locations.last
        
        // Reverse geocode to get human-readable address
        if let location = location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    // Create a formatted address from placemark components
                    var addressString = ""
                    
                    if let name = placemark.name {
                        addressString += name
                    }
                    
                    if let thoroughfare = placemark.thoroughfare {
                        addressString += addressString.isEmpty ? thoroughfare : ", \(thoroughfare)"
                    }
                    
                    if let locality = placemark.locality {
                        addressString += addressString.isEmpty ? locality : ", \(locality)"
                    }
                    
                    if addressString.isEmpty {
                        addressString = "Unknown Location"
                    }
                    
                    // Update location name on the main thread
                    DispatchQueue.main.async {
                        self?.locationName = addressString
                    }
                }
            }
        }
    }
    
    /// Called when location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        locationName = "Location unavailable"
    }
}
