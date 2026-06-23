//
//  SearchViewModel.swift
//  iOSApp3
//
//  Created by Chibuzor Emmanuel Awanye on 2026-06-20.
//

import Foundation

// The ViewModel for the search screen.
// @MainActor ensures all property updates happen on the main thread,
// which is required for SwiftUI to pick up changes safely.
@Observable
@MainActor
class SearchViewModel {

    // Text the user types into the search bar
    var searchText: String = ""

    // Results from the most recent search
    var artworks: [Artwork] = []

    // True while a network request is in flight — drives the loading spinner
    var isLoading: Bool = false

    // Set when a network error occurs — drives the error alert
    var errorMessage: String? = nil

    private let baseURL = "https://api.artic.edu/api/v1"

    // Only request the fields we actually display in the list row.
    private let searchFields = "id,title,artist_display,date_display,medium_display,image_id"

    // Request extra fields when fetching a single artwork for the detail screen
    private let detailFields = [
        "id", "title", "artist_display", "date_display", "medium_display",
        "image_id", "description", "place_of_origin", "dimensions", "department_title"
    ].joined(separator: ",")

    // Searches the ARTIC collection for artworks matching `searchText`.
    // Called when the user taps the Search key on the keyboard.
    func searchArtworks() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        artworks = []

        // Percent-encode the query so spaces/special characters are URL-safe
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/artworks/search?q=\(encoded)&fields=\(searchFields)&limit=25"

        guard let url = URL(string: urlString) else {
            errorMessage = "Could not build a valid search URL."
            isLoading = false
            return
        }

        do {
            // async/await suspends here while the network request runs,
            // keeping the UI fully responsive — same pattern as the tutorial
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            artworks = decoded.data
        } catch {
            errorMessage = "Search failed. Check your connection and try again."
        }

        isLoading = false
    }

    // Fetches the full detail record for a single artwork by its ID.
    // Called from ArtworkDetailView using .task when the detail screen appears.
    // Returns nil silently on failure — the detail view falls back to search result data.
    func fetchArtworkDetail(id: Int) async -> Artwork? {
        let urlString = "\(baseURL)/artworks/\(id)?fields=\(detailFields)"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(SingleArtworkResponse.self, from: data)
            return decoded.data
        } catch {
            // Return nil so the detail view gracefully falls back to the search result
            return nil
        }
    }
}
