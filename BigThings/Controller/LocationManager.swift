import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationStatus: CLAuthorizationStatus?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Don't request permissions here; let the delegate method handle it
        checkLocationServicesEnabled()
    }
    
    // Check if location services are enabled
    func checkLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            // Check the current authorization status
            checkLocationAuthorization()
        } else {
            print("Location services are disabled.")
        }
    }
    
    // Handle changes in authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.locationStatus = status
        }

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            self.locationManager.startUpdatingLocation()  // Only start location updates if authorized
        case .denied, .restricted:
            print("Location access denied or restricted")
        case .notDetermined:
            print("Requesting location access")
            // Request authorization here when the state is 'notDetermined'
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    // Update location when received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
                print("User location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
    }

    // Handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    // Check the current authorization status
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Location services are authorized, start updating the location
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Location services denied or restricted
            print("Location access denied or restricted.")
        case .notDetermined:
            // Do not request authorization here; let the delegate method handle it
            print("Location access not determined. Waiting for user action.")
        @unknown default:
            print("Unknown authorization status")
        }
    }
}
