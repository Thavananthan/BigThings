import SwiftUI

struct StarRatingView: View {
    var rating: Double
    var maxRating: Int = 5  // Maximum number of stars

    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                    .foregroundColor(index <= Int(rating) ? .yellow : .gray)
            }
        }
    }
}
