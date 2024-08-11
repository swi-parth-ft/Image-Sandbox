//
//  Variations.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import SwiftUI

import PhotosUI

struct Variations: View {
    @State private var userInput: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var modifiedImage: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var errorMessage: String? = nil
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: Image?
    var body: some View {
        VStack {
            TextField("Enter keywords for the image (e.g., superhero, birthday)", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Select Image")
            }
            .padding()
            
            PhotosPicker(selection: $selectedItem) {
                Text("Add")
            }
            .onChange(of: selectedItem, loadImage)
            
            
            Button(action: generateImage) {
                Text("Generate Cartoon Image")
            }
            .padding()
            .disabled(userInput.isEmpty || selectedImage == nil || isLoading)
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            if let image = modifiedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
       
    }
    
    func loadImage() {
  
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            selectedImage = inputImage
           
        }
    }
    
    func generateImage() {
        guard let selectedImage = selectedImage else { return }
        
        isLoading = true
        errorMessage = nil
        OpenAI.shared.createImageVariation(image: selectedImage, prompt: userInput) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let image):
                    self.modifiedImage = image
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    Variations()
}
