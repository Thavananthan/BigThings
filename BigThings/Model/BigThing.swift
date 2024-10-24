
import Foundation
struct BigThing: Identifiable, Codable {
    var id: String
    var name: String
    var location: String
    var description: String
    var rating: String
    var latitude: String
    var longitude: String
    var image: String
    var isFavorite: Bool?
    var isVisited: Bool?
    var hasRated:Bool?
}
