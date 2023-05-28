//
//  ItemListView.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI

struct ItemListView: View {
    @ObservedObject var viewModel = ItemViewModel()
    @AppStorage("ShowImages") private var showImages: Bool = false
    @State private var cardImages: [String: UIImage] = [:]
    @State private var isURLValid = true

    var body: some View {
        VStack {
            if !viewModel.errorMessage.isEmpty {
                Text("The URL could not be opened, please try again later")
                    .foregroundColor(.red)
                    .padding()
            }

            HStack {
                Button(action: { viewModel.fetchData() }) {
                    Text("Reload Items")
                        .foregroundColor(viewModel.isLoading ? .black : .blue)
                        .padding()
                }
                .disabled(viewModel.isLoading)
            }

            List(Array(Set(viewModel.cards)).sorted { $0.name ?? "" < $1.name ?? "" }) { card in
                NavigationLink(destination: ItemDetailView(card: card)) {
                    HStack {
                        if showImages,
                           let image = cardImages[card.id] {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 80)
                        } else if showImages {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                        Text(card.name ?? "")
                            .fontWeight(card == viewModel.cards.first ? .bold : .regular)
                    }
                    .padding()
                }
                .onAppear {
                    loadImage(for: card)
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("03_kelmendi", displayMode: .inline)
                .background(card == viewModel.cards.first ? Color.yellow : Color.clear)
            }
        }
        .onChange(of: showImages) { newValue in
            UserDefaults.standard.set(newValue, forKey: "ShowImages")
        }
        .onChange(of: UserDefaults.standard.string(forKey: "APIURL")) { newValue in
            reloadItemsIfNeeded()
        }
        .onAppear {
            reloadItemsIfNeeded()
        }
    }

    func loadImage(for card: Card) {
        guard let imageURLString = card.imageUrl,
              let imageURL = URL(string: imageURLString) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cardImages[card.id] = image
                }
            }
        }.resume()
    }

    func reloadItemsIfNeeded() {
        if let savedURLString = UserDefaults.standard.string(forKey: "APIURL"),
           !savedURLString.trimmingCharacters(in: .whitespaces).isEmpty,
           let savedURL = URL(string: savedURLString) {
            viewModel.fetchData(url: savedURL)
        } else {
            let standardURLString = "https://api.scryfall.com/cards/search?order=cmc&q=c%3Ared+pow%3D8"
            let standardURL = URL(string: standardURLString)!
            viewModel.fetchData(url: standardURL)
        }
    }


 }

