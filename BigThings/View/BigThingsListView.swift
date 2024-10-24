import SwiftUI

struct BigThingsListView: View {
    @ObservedObject var viewModel = BigThingsViewModel()
    
    @State private var searchText = ""  // Search query for filtering
    @State private var selectedSortOption = "Name"
    
    // Filter and sort the Big Things
    var filteredAndSortedBigThings: [BigThing] {
        let filteredBigThings = viewModel.bigThings.filter { bigThing in
            searchText.isEmpty || bigThing.name.localizedCaseInsensitiveContains(searchText) || bigThing.location.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedSortOption {
        case "Name":
            return filteredBigThings.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case "Rating":
            return filteredBigThings.sorted { Double($0.rating) ?? 0 > Double($1.rating) ?? 0 }  // Sort by rating in descending order
        default:
            return filteredBigThings
        }
    }
    func isImageURL(_ imageString: String) -> Bool {
        if let url = URL(string: imageString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func isBase64Image(_ imageString: String) -> Bool {
        // Check if the string looks like a Base64 string (alphanumeric and some specific characters)
        let base64Pattern = #"^[A-Za-z0-9+/=]+$"#
        let regex = try! NSRegularExpression(pattern: base64Pattern)
        let range = NSRange(location: 0, length: imageString.count)
        
        return regex.firstMatch(in: imageString, options: [], range: range) != nil
    }
    
    func imageFromBase64String(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Sorting Picker
                Picker("Sort by", selection: $selectedSortOption) {
                    Text("Name").tag("Name")
                    Text("Rating").tag("Rating")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List{ ForEach(filteredAndSortedBigThings, id: \.id) { bigThing in
                    NavigationLink(destination: BigThingDetailView(viewModel: viewModel,bigThing: bigThing)) {
                        HStack {
                           
                                AsyncImage(url: URL(string: "https://www.partiklezoo.com/bigthings/images/\(bigThing.image)")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else if phase.error != nil {
                                        Image(systemName: "photo")
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            
                        }
                        VStack(alignment: .leading) {
                            Text(bigThing.name)
                                .font(.headline)
                            Text(bigThing.location)
                                .font(.subheadline)
                        }
                        
                    }
                }
                }
            }
            .searchable(text: $searchText, prompt: "Search by name or state")
            .navigationTitle("Big Things")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SubmitBigThingView(viewModel: viewModel)) {
                        Text("Add")
                        Image(systemName: "plus.circle.fill")  // System icon
                            .foregroundColor(.black)// Button text
                    }
                }
            }
        }
    }
}

