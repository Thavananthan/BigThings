import SwiftUI
import UIKit

struct SubmitBigThingView: View {
    @ObservedObject var viewModel: BigThingsViewModel
    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var address = ""
    @State private var userName = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera  // Default sourceType as camera
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Text fields for input
                TextField("Big Thing Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Latitude", text: $latitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Longitude", text: $longitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Address (if no GPS)", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Display selected image preview
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding(.vertical)
                }

                // Button to open camera or photo library
                Button(action: {
                    isShowingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Capture or Select Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                }

                // Submit Button
                Button(action: {
                    validateAndSubmit()
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Big Thing")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Submit a Big Thing")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Validate Input Fields and Submit
    private func validateAndSubmit() {
        if name.isEmpty || address.isEmpty || userName.isEmpty {
            // If name, address, or description is empty, show an alert
            alertMessage = "Please fill in all the required fields (Name, Address, and Description)."
            showAlert = true
            return
        }
        
        // All required fields are filled, proceed with submission
        viewModel.submitNewBigThing(
            name: name,
            latitude: latitude.isEmpty ? nil : latitude,
            longitude: longitude.isEmpty ? nil : longitude,
            address: address.isEmpty ? nil : address,
            description: userName.isEmpty ? nil : userName,
            photo: selectedImage
        )
        
        // Clear the fields after successful submission
        clearFormFields()
        
        // Show a success message (you can update this as needed)
        alertMessage = "Big Thing submitted successfully!"
        showAlert = true
    }

    // MARK: - Clear Form Fields After Submission
    private func clearFormFields() {
        name = ""
        latitude = ""
        longitude = ""
        address = ""
        userName = ""
        selectedImage = nil
    }
}
