//
//  ContentView.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = """
        Create a vibrant, birthday illustration. The scene should capture a cheerful character and festive elements. Include:
            
            - A character (John) engaging in activities related to creativity, humor, and celebration.
            - A background that reflects fun and joy, with decorations like balloons and confetti.
            
            The tone should be lighthearted and whimsical, reflecting a joyful and festive atmosphere.
        Reflect the following theme in the illustration: Happy 45th Birthday, Maa! Your kindness amazes me every day, just like that time when I finally saw you after 3 long years and you welcomed me with open arms. Your teaching skills are top-notch, but your ability to love unconditionally is what truly shines. Here's to many more years of laughter and love!
        """
    
    
    
    

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
    
    func generateImagePrompt(from birthdayMessage: String) -> String {
        // Define base prompt structure
        let basePrompt = """
        Create a vibrant, cartoonish birthday illustration featuring a cheerful character named John. The scene should include the following elements:

        1. John holding a paintbrush and standing next to a canvas with a colorful painting.
        2. A football field in the background with a football team scoring a touchdown.
        3. A few funny jokes or puns in speech bubbles around John, making it clear that he is known for his humor.
        4. Bright, festive decorations like balloons, confetti, and a 'Happy Birthday' banner.

        The overall tone should be lighthearted and whimsical, capturing the essence of celebration, creativity, and fun. Make sure the image conveys joy and excitement, reflecting the birthday wishes of laughter, art, and touchdowns.
        """
        
        // Append the user’s message to the base prompt
        let userPrompt = """
        \(basePrompt)

        Incorporate the following message into the illustration: \(birthdayMessage)
        """

        return userPrompt
    }
}


#Preview {
    ContentView()
}
