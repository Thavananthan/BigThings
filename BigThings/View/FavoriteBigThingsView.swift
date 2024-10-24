

import Foundation
import SwiftUI

struct FavoriteBigThingsView: View {
    @ObservedObject var viewModel = BigThingsViewModel()
    @State private var refreshFlag = false  // To trigger view refresh

    var body: some View {
        NavigationView {
            List(viewModel.favoriteBigThings, id: \.id) { bigThing in
                HStack {
                    AsyncImage(url: URL(string: "https://www.partiklezoo.com/bigthings/images/\(bigThing.image!)")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if phase.error != nil {
                            Image(systemName: "photo")
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(bigThing.name!)
                            .font(.headline)
                        Text(bigThing.location!)
                            .font(.subheadline)
                    }
                }
            } .onAppear{
                viewModel.fetchFavorites()
                refreshFlag.toggle()  // Force a UI update

            }
            .navigationTitle("Favorite Big Things")
            
        }
    }
}
