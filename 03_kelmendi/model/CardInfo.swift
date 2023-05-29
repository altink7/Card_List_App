//
//  CardInfo.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 29.05.23.
//

import Foundation

struct Response<T: Codable>: Codable {
    let data: [T]
}

struct CardInfo: Codable, Identifiable, Hashable {
    let id: String
    let name: String?
    let oracleText: String?
    let imageUris: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case oracleText
        case imageUris
    }

    var imageUrl: String? {
        if let imageUris = imageUris {
            return imageUris["normal"] ?? imageUris["large"] ?? imageUris["small"]
        }
        return nil
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: CardInfo, rhs: CardInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
