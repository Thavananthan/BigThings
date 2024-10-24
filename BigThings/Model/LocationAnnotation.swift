import SwiftUI
import MapKit
import CoreLocation

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isBigThing: Bool
}
