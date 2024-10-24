

import Foundation
import Foundation
import Combine
import CoreData
import SwiftUI

class BigThingsViewModel: ObservableObject {
    @Published var bigThings: [BigThing] = []
    @Published var favoriteBigThings: [BigThingEntity] = []
    @Published var selectedBigThing: [BigThing] = []  // Store the downloaded Big Thing
    @Published var RatingBigThing: [RatingEntity] = []

    private var cancellables = Set<AnyCancellable>()
    @Published var showAlert = false               // Tracks whether the alert should be shown
    @Published var alertMessage: String = ""
    
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "AppThingsModel")
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        
        storeDescription?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        storeDescription?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            } else {
                print("Core Data loaded successfully with migration options")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        fetchBigThings()
        fetchFavorites()
    }
  
    func triggerAlert(with message: String) {
            alertMessage = message
            showAlert = true
    }
    
    func fetchBigThings() {
        guard let url = URL(string: "https://www.partiklezoo.com/bigthings/") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [BigThing].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching Big Things: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] bigThings in
                self?.bigThings = bigThings
            })
            .store(in: &cancellables)
    }
    
    func saveBigThingAsFavorite(_ bigThing: BigThing) {
        let fetchRequest: NSFetchRequest<BigThingEntity> = BigThingEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", bigThing.id as CVarArg)
        
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.isEmpty {
                // Create a new entity and save it
                let favoriteBigThing = BigThingEntity(context: persistentContainer.viewContext)
                favoriteBigThing.id = bigThing.id
                favoriteBigThing.name = bigThing.name
                favoriteBigThing.location = bigThing.location
                favoriteBigThing.desc = bigThing.description
                favoriteBigThing.rating = Double(bigThing.rating) ?? 0.0
                favoriteBigThing.latitude = bigThing.latitude
                favoriteBigThing.longitude = bigThing.longitude
                favoriteBigThing.image = bigThing.image
                favoriteBigThing.isFavorite = true
                
                do {
                    try persistentContainer.viewContext.save()
                    print("Big Thing added to favorites")
                } catch let saveError as NSError {
                    // Log full error details to see what’s going wrong
                    print("Failed to save the Big Thing: \(saveError), \(saveError.userInfo)")
                }
            } else {
                self.triggerAlert(with: "\(bigThing.name) is already a favorite") // Show error alert

                print("Big Thing is already a favorite")
            }
        } catch let fetchError as NSError {
            // Log full error details to diagnose fetch failure
            print("Failed to fetch Big Thing: \(fetchError), \(fetchError.userInfo)")
        }
    }
    
    func fetchFavorites() {
        let request: NSFetchRequest<BigThingEntity> = BigThingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == true")
        
        do {
            favoriteBigThings = try persistentContainer.viewContext.fetch(request)
            print("fetchFavorites big thing")
            for favorite in favoriteBigThings {
                print("Favorite Big Thing: \(favorite.name)")
            }
            
        } catch {
            print("Error fetching favorites: \(error.localizedDescription)")
        }
    }
    
//    func fetchDownload() {
//        let request: NSFetchRequest<BigThingEntity> = BigThingEntity.fetchRequest()
//        request.predicate = NSPredicate(format: "isFavorite == true")
//        
//        do {
//            selectedBigThing = try persistentContainer.viewContext.fetch(request)
//            print("fetchFavorites big thing")
//            for download in selectedBigThing {
//                print("Favorite Big Thing: \(download.name)")
//            }
//            
//        } catch {
//            print("Error fetching favorites: \(error.localizedDescription)")
//        }
//    }
    
    
    func resetCoreDataStore() {
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        let storeURL = persistentContainer.persistentStoreDescriptions.first?.url
        
        do {
            if let storeURL = storeURL {
                try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                print("Old store destroyed successfully.")
            }
        } catch {
            print("Error destroying old store: \(error.localizedDescription)")
        }
        
        // Reload the persistent store after deletion
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            } else {
                print("Core Data store recreated successfully.")
            }
        }
    }
    
    // Rate a Big Thing and save both locally and via API
    func rateBigThing(_ bigThing: BigThing, newRating: Double) {
        let fetchRequest: NSFetchRequest<RatingEntity> = RatingEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", bigThing.id as CVarArg)
        
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.isEmpty {
                // Create a new entity and save it
                let ratingBigThing = RatingEntity(context: persistentContainer.viewContext)
                ratingBigThing.id = bigThing.id
                ratingBigThing.rating = newRating
                ratingBigThing.votes = "1"
                do {
                    try persistentContainer.viewContext.save()
                    print("Big Thing rated locally with new rating: \(newRating)")
                    submitRatingToAPI(for: bigThing, rating: newRating)
                } catch let saveError as NSError {
                    // Log full error details to see what’s going wrong
                    print("Failed to save the Big Thing: \(saveError), \(saveError.userInfo)")
                }
            } else {
                self.triggerAlert(with: "Rating  already submitted for \(bigThing.name)") // Show error alert
                print("Big Thing is already a favorite")
            }
            
        } catch let fetchError as NSError {
            print("Failed to fetch or rate Big Thing: \(fetchError), \(fetchError.userInfo)")
        }
    }
    
    
    // Function to submit rating to external API
    func submitRatingToAPI(for bigThing: BigThing, rating: Double) {
        guard let url = URL(string: "https://www.partiklezoo.com/bigthings/?action=rate&id=\(bigThing.id)&rating=\(rating)") else {
            print("Invalid URL for rating API.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting rating: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server.")
                return
            }
            
            print("Rating submitted successfully to API.")
            self.triggerAlert(with: "Rating submitted successfully to API") // Show error alert

        }
        
        task.resume()
    }
    
    func downloadBigThingRecord(by id: String) {
        if selectedBigThing.contains(where: { $0.id == id }) {
                    print("Error: Big Thing with ID \(id) has already been downloaded.")
            self.triggerAlert(with: "Big Thing with ID \(id) has already been downloaded.") // Show error alert

                    return  // Prevent downloading the same record again
                }
            // Construct the URL
            guard let url = URL(string: "https://www.partiklezoo.com/bigthings/?action=record&id=\(id)") else {
                print("Invalid URL")
                return
            }

            // Fetch the data from the API
        URLSession.shared.dataTaskPublisher(for: url)
               .map { $0.data }
               .decode(type: [BigThing].self, decoder: JSONDecoder())
               .receive(on: DispatchQueue.main)
               .sink(receiveCompletion: { completion in
                   if case .failure(let error) = completion {
                       print("Failed to fetch Big Thing: \(error.localizedDescription)")
                   }
               }, receiveValue: { [weak self] bigThings in
                   print("Downloaded \(bigThings.count) Big Things")
                   bigThings.forEach { print($0.name) }

                   self?.objectWillChange.send() // Force SwiftUI to re-render the view
                   self?.selectedBigThing.append(contentsOf: bigThings)
               })
               .store(in: &cancellables)
        }
    func submitNewBigThing(name: String, latitude: String?, longitude: String?, address: String?, description: String?, photo: UIImage?) {

        // Prepare the new Big Thing data
        var newBigThing: [String: Any] = [
            "name": name,
        ]
        
        // Add optional fields
        if let lat = latitude, let long = longitude {
            newBigThing["latitude"] = lat
            newBigThing["longitude"] = long
        } else if let addr = address {
            newBigThing["address"] = addr
        }
        
        if let description = description {
            newBigThing["description"] = description
        }
        
        // Handle image conversion to Base64
        if let image = photo {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let base64ImageString = imageData.base64EncodedString()
                newBigThing["image"] = base64ImageString  // Include the image in the request
            }
        }

        // Build the request
        guard let url = URL(string: "https://www.partiklezoo.com/bigthings/?action=submit") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Prepare the request body with JSON encoding
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: newBigThing, options: [])
            request.httpBody = requestBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        // Submit the data using URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting new Big Thing: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                return
            }
            
            print("New Big Thing submitted successfully!")
            
            // Optionally add the new Big Thing locally (without API response)
            DispatchQueue.main.async {
                self.addBigThingLocally(name: name, latitude: latitude, longitude: longitude, address: address, description: description, image:photo)
            }
        }
        .resume()
    }


    // Function to add the new Big Thing locally in the array
    private func addBigThingLocally(name: String, latitude: String?, longitude: String?, address: String?, description: String?, image: UIImage?) {
        
        // Convert UIImage to Base64 string if needed
        var base64ImageString = ""
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            base64ImageString = imageData.base64EncodedString()
        }
        
        let newBigThing = BigThing(
            id: UUID().uuidString,
            name: name,
            location: address ?? "Unknown Location",
            description: description ?? "No description provided",
            rating: "0.0",
            latitude: latitude ?? "0.0",
            longitude: longitude ?? "0.0",
            image: base64ImageString,  // Store the Base64 string as the image field
            isFavorite: false,
            isVisited: false
        )
        
        // Append the new Big Thing to the bigThings array
        bigThings.append(newBigThing)
        print("New Big Thing added locally: \(newBigThing.name)")
    }

    
}
