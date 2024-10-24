import SwiftUI
import MapKit
import CoreLocation


struct BigThingDetailView: View {
    @ObservedObject var viewModel: BigThingsViewModel
    var bigThing: BigThing
    
    @State private var rating: Double = 0.0
    @StateObject private var locationManager = LocationManager()  // Track user location
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), // Default center
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    struct LocationAnnotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let isBigThing: Bool
    }
    
    // Helper functions to wrap the annotations
    func bigThingAnnotation(latitude: Double, longitude: Double) -> LocationAnnotation {
        return LocationAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), isBigThing: true)
    }
    
    func userLocationAnnotation(_ location: CLLocationCoordinate2D) -> LocationAnnotation {
        return LocationAnnotation(coordinate: location, isBigThing: false)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Big Thing Image with rounded corners and shadow
                AsyncImage(url: URL(string: "https://www.partiklezoo.com/bigthings/images/\(bigThing.image)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                            .padding(.bottom, 10)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                    }
                }
                
                // Big Thing Location
                Text(bigThing.location)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Rating:")
                        .font(.headline)
                    
                    StarRatingView(rating: Double(bigThing.rating) ?? 0.0)  // Display stars based on rating
                }
                .padding(.vertical)
                // Big Thing Description
                Text(bigThing.description)
                    .font(.body)
                    .padding(.vertical)
                    .lineLimit(nil)
                // Map Section with both the Big Thing location and user's location
                if let latitude = Double(bigThing.latitude), let longitude = Double(bigThing.longitude), let userLocation = locationManager.userLocation {
                    Map(coordinateRegion: $region, annotationItems: [bigThingAnnotation(latitude: latitude, longitude: longitude), userLocationAnnotation(userLocation)]) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            if annotation.isBigThing {
                                // Big Thing Marker
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                    Text(bigThing.name)
                                        .font(.caption)
                                }
                            } else {
                                // User Location Marker
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .onAppear {
                        // Update the map's region when the view appears
                        self.region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    }
                } else if let userLocation = locationManager.userLocation {
                    // Show user location only if Big Thing's coordinates are invalid
                    Map(coordinateRegion: $region, annotationItems: [userLocationAnnotation(userLocation)]) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            Image(systemName: "location.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .onAppear {
                        self.region = MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    }
                } else {
                    Text("Fetching location or invalid Big Thing coordinates.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                // Rating Section with Slider
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rate this Big Thing")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: $rating, in: 0...5, step: 0.5)
                        Text(String(format: "%.1f", rating))
                            .font(.headline)
                    }
                    
                    // Submit Rating Button
                    Button(action: {
                        viewModel.rateBigThing(bigThing, newRating: rating)
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Submit Rating")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.vertical)
                
                // Mark as Favorite Button
                Button(action: {
                    viewModel.saveBigThingAsFavorite(bigThing)
                }) {
                    HStack {
                        Image(systemName: (bigThing.isFavorite ?? false) ? "heart.fill" : "heart")
                        Text((bigThing.isFavorite ?? false) ? "Favorited" : "Mark as Favorite")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.vertical, 10)
                
                // Download Button
                Button(action: {
                    viewModel.downloadBigThingRecord(by: bigThing.id)
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download Details")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.vertical, 10)
                
                Spacer()
            }
            .padding()
            .navigationTitle(bigThing.name)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Notification"),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Load existing rating if available
                self.rating = rating ?? 0.0
                //viewModel.downloadBigThingRecord(by: bigThing.id)
            }
        }
    }
}
