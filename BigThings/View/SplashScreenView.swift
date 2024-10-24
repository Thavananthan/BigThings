import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8  // Logo scaling for zoom animation
    @State private var rotationAngle: Double = 0.0  // Logo rotation
    @State private var opacity: Double = 0.0  // Text fade-in effect

    var body: some View {
        VStack {
           
                VStack {
                    // Rotating Logo
                    Image("logo") // Replace with your logo image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(logoScale)  // Apply zoom effect
                        .rotationEffect(.degrees(rotationAngle))  // Apply rotation effect
                        .padding()

                    // Company Name
                    Text("BigThings Corp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                        .opacity(opacity)  // Fade-in effect
                    
                    // Tagline
                    Text("Discover the Wonders of Australia's Big Things")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(opacity)  // Fade-in effect
                }
                .onAppear {
                    // Start the animations
                    withAnimation(.easeInOut(duration: 1.5)) {
                        self.logoScale = 1.0  // Scale the logo up
                        self.rotationAngle = 360  // Full rotation of logo
                    }
                    
                    // Simulate text fade-in after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.opacity = 1.0  // Fade in the text
                        }
                    }
                    

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
