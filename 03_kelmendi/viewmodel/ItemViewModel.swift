//
//  ItemViewModel.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 20.05.23.
//

import Foundation
import SwiftUI
import CoreData

class ItemViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var apiURL: String {
        return UserDefaults.standard.string(forKey: "APIURL") ?? "https://api.scryfall.com/cards/search?order=cmc&q=c%3Ared+pow%3D8"
    }

    private let dataHandler: DataHandler

    init(dataHandler: DataHandler = DataHandler.shared) {
        self.dataHandler = dataHandler
    }

    func fetchData(url: URL? = nil) {
        cards = []
        isLoading = true
        errorMessage = ""

        let url = url ?? URL(string: apiURL)!
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.errorMessage = error?.localizedDescription ?? "Unknown error"
                    self?.isLoading = false
                }
                return
            }

            self?.parse(jsonData: data)
        }.resume()
    }

    private func parse(jsonData: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(Response<CardInfo>.self, from: jsonData)
            let cardInfos = response.data

            let context = DataHandler.shared.persistentContainer.viewContext

            var cards: [Card] = []
            for cardInfo in cardInfos {
                let card = Card(context: context)
                card.id = cardInfo.id

                if let imageUris = cardInfo.imageUris, let imageUrl = imageUris["normal"] {
                    card.imageUrl = imageUrl
                }

                card.name = cardInfo.name
                card.oracleText = cardInfo.oracleText
                cards.append(card)
            }

            try context.save()

            DispatchQueue.main.async {
                if cards.isEmpty {
                    self.errorMessage = "No valid cards found."
                } else {
                    self.cards = cards.sorted { ($0.name ?? "") < ($1.name ?? "") }
                }
                self.isLoading = false
            }
        } catch let error {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("Error decoding JSON: \(error)")
            print(String(data: jsonData, encoding: .utf8) ?? "No data received")
        }
    }
}



