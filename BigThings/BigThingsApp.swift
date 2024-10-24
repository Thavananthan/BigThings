
import SwiftUI

@main
struct BigThingsApp: App {
    @State private var showSplashScreen = true // Track whether the splash screen is showing

    var body: some Scene {
            WindowGroup {
                if showSplashScreen {
                    SplashScreenView() // Show the splash screen first
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                // After 3 seconds, switch to the main content
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                        }
                } else {
                    // The main content of your app (e.g., TabView with the list)
                    TabView {
                        BigThingsListView()
                            .tabItem {
                                Label("Big Things", systemImage: "list.dash")
                            }
                        FavoriteBigThingsView()
                            .tabItem {
                                Label("Favorites", systemImage: "star.fill")
                            }
                        AboutBigThingsView()
                            .tabItem{
                                Label("About", systemImage: "quote.bubble")
                            }
                    }
                }
            }
        }
}
