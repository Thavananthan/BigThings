import SwiftUI

struct AboutBigThingsView: View {
    var body: some View {
        ScrollView {
            ZStack {
                // Background Image
                Image("travel-about") // Replace with an actual image name from your assets
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxHeight: 500)  // Limit height to avoid overpowering the text
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                                       startPoint: .bottom,
                                       endPoint: .top)
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                    // Heading
                    Text("About Big Things")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .padding(.horizontal)
                    
                    // Body Text
                    Text("""
The big things of Australia are a loosely related set of large structures, some of which are novelty architecture and some are sculptures.

There are estimated to be over 150 such objects around the country, spread across every state and territory in continental Australia.

Most big things began as tourist attractions found along major roads between destinations, and they have become something of a cult phenomenon.

Big things are often visited as part of a road trip, with many travelers using them as backdrops for group photos. Some are considered works of folk art and have even been heritage-listed, though others have faced threats of demolition.
""")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding([.horizontal, .bottom])
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
          // Black background to blend with the gradient and image
    }
}


