

import Foundation
import SwiftUI
import Combine

struct RemoteImage: View {
    @StateObject private var loader: ImageLoader
    var loading: Image
    var failure: Image
    
    var body: some View {
        selectImage()
            .resizable()
            .scaledToFit()
    }
    
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            return Image(uiImage: loader.image ?? UIImage())
        }
    }
    
    init(url: URL, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "exclamationmark.triangle")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.loading = loading
        self.failure = failure
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var state = LoadingState.loading
    
    private let url: URL
    private var cancellable: AnyCancellable?
    
    enum LoadingState {
        case loading, success, failure
    }
    
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    private func loadImage() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let image = $0 {
                    self?.image = image
                    self?.state = .success
                } else {
                    self?.state = .failure
                }
            }
    }
}
