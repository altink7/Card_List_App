//
//  ItemDetailView.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI;

struct ItemDetailView: View {
    let card: Card
    @AppStorage("ShowImages") private var showImages: Bool = false
    @State private var cardImage: UIImage?
    
    var body: some View {
        VStack {
            if let imageURL = card.imageUrl,
               let url = URL(string: imageURL) {
                ZStack(alignment: .bottomLeading) {
                    if showImages, let image = cardImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name ?? "no name")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(card.id)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                }
                .frame(maxHeight: 200)
            }
            
            Text("").padding()
            Text("").padding()
            Text("").padding()
        
            Text(card.oracleText ?? "")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 16)
            
            Button(action: {
                if let imageURL = card.imageUrl,
                   let url = URL(string: imageURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Image URL")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            loadImage()
        }
    }
    
    func loadImage() {
        guard let imageURLString = card.imageUrl,
              let imageURL = URL(string: imageURLString) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cardImage = image
                }
            }
        }.resume()
    }
}

