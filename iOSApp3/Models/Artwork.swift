//
//  Artwork.swift
//  iOSApp3
//
//  Created by Chibuzor Emmanuel Awanye on 2026-06-20.
//

import Foundation

// Represents a single artwork from the Art Institute of Chicago collection.
// Conforms to Codable so JSONDecoder can decode it directly from the API response.
// Conforms to Identifiable so SwiftUI can use it in List and ForEach.
struct Artwork: Codable, Identifiable {
    let id: Int
    let title: String

    // Optional because not every artwork in the collection has all fields filled in
    let artistDisplay: String?
    let dateDisplay: String?
    let mediumDisplay: String?
    let imageId: String?

    // These fields are only returned when fetching a single artwork by ID,
    // not in the search results list — so they start as nil
    let description: String?
    let placeOfOrigin: String?
    let dimensions: String?
    let departmentTitle: String?

    // The ARTIC API returns JSON with snake_case keys.
    // CodingKeys maps them to Swift's camelCase naming convention.
    enum CodingKeys: String, CodingKey {
        case id, title, description, dimensions
        case artistDisplay   = "artist_display"
        case dateDisplay     = "date_display"
        case mediumDisplay   = "medium_display"
        case imageId         = "image_id"
        case placeOfOrigin   = "place_of_origin"
        case departmentTitle = "department_title"
    }

    // Builds a thumbnail URL using ARTIC's IIIF image server.
    // Returns nil if this artwork has no associated image.
    var thumbnailURL: URL? {
        guard let imageId else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/400,/0/default.jpg")
    }

    // The ARTIC API returns description as HTML (e.g. "<p>Monet painted…</p>").
    // This strips the tags so we can display plain text in SwiftUI.
    var strippedDescription: String? {
        guard let description else { return nil }
        return description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Wraps the array of artworks returned by a search query.
struct SearchResponse: Codable {
    let data: [Artwork]
}

// Wraps the single artwork returned when fetching full details.
struct SingleArtworkResponse: Codable {
    let data: Artwork
}
