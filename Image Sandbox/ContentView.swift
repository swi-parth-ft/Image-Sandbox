//
//  ContentView.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var generatedImage: UIImage? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            TextField("Enter a prompt for the image", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: generateImage) {
                Text("Generate Image")
            }
            .padding()
            .disabled(userInput.isEmpty || isLoading)
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            if let image = generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
        .padding()
    }
    
    func generateImage() {
        isLoading = true
        let prompt = userInput
        OpenAIService.shared.generateImage(from: prompt) { result in
            isLoading = false
            switch result {
            case .success(let image):
                self.generatedImage = image
            case .failure(let error):
                print("Error generating image: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    ContentView()
}
