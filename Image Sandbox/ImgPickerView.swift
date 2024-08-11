//
//  ImgPickerView.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import SwiftUI
import PhotosUI

struct ImgPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: Image?
    var body: some View {
        PhotosPicker(selection: $selectedItem) {
            Text("Add")
        }
        .onChange(of: selectedItem, loadImage)
        
        if let image = image {
            image
                .resizable()
                .scaledToFit()
        }
    }
    
    func loadImage() {
  
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            image = Image(uiImage: inputImage)
           
        }
    }
}

#Preview {
    ImgPickerView()
}
