//
//  ItemListView.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var viewModel: ItemViewModel
    @AppStorage("ShowImages") private var showImages: Bool = false
    @State private var isURLValid = true

    var body: some View {
        VStack {
            if !viewModel.errorMessage.isEmpty {
                Text("The URL could not be opened, please try again later")
                    .foregroundColor(.red)
                Text(viewModel.errorMessage)
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
                        if showImages {
                            AsyncImage(url: URL(string: card.imageUrl ?? "")) { image in
                                image
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                        }
                        Text(card.name ?? "")
                            .fontWeight(card == viewModel.cards.first ? .bold : .regular)
                    }
                    .padding()
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

