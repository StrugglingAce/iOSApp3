//
//  ArtworkDetailView.swift
//  iOSApp3
//
//  Created by Chibuzor Emmanuel Awanye on 2026-06-21.
//

import SwiftUI

// The full detail screen for a single artwork.
// Uses .task to fetch richer data (description, dimensions, etc.) on appear
struct ArtworkDetailView: View {

    // Basic info passed in from the search results list
    let artwork: Artwork

    // Used to call fetchArtworkDetail when this view appears
    let viewModel: SearchViewModel

    // Populated by the detail fetch; nil until it completes
    @State private var detailedArtwork: Artwork? = nil
    @State private var isLoadingDetail = false

    // Returns the richest data available —
    // full detail once fetched, basic search result as the fallback
    private var display: Artwork {
        detailedArtwork ?? artwork
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Full-width hero image
                heroImage

                VStack(alignment: .leading, spacing: 16) {

                    Text(display.title)
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    // Info rows — only appear when the field has data
                    if let artist = display.artistDisplay {
                        InfoRow(label: "Artist", value: artist)
                    }
                    if let date = display.dateDisplay {
                        InfoRow(label: "Date", value: date)
                    }
                    if let medium = display.mediumDisplay {
                        InfoRow(label: "Medium", value: medium)
                    }
                    // These three only appear after the detail fetch completes
                    if let place = display.placeOfOrigin {
                        InfoRow(label: "Origin", value: place)
                    }
                    if let dimensions = display.dimensions {
                        InfoRow(label: "Dimensions", value: dimensions)
                    }
                    if let department = display.departmentTitle {
                        InfoRow(label: "Department", value: department)
                    }

                    // Small spinner shown while the detail request is in flight
                    if isLoadingDetail {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Loading details...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Description only comes from the detail endpoint
                    if let desc = display.strippedDescription, !desc.isEmpty {
                        Divider()
                        Text("About This Work")
                            .font(.headline)
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(display.title)
        .navigationBarTitleDisplayMode(.inline)
        // .task runs when the view appears and cancels automatically if the user
        // navigates back before it finishes
        .task {
            isLoadingDetail = true
            detailedArtwork = await viewModel.fetchArtworkDetail(id: artwork.id)
            isLoadingDetail = false
        }
    }

    private var heroImage: some View {
        AsyncImage(url: display.thumbnailURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 300)
                    .overlay { ProgressView() }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

            case .failure:
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                            Text("Image not available")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }

            @unknown default:
                EmptyView()
            }
        }
    }
}

// A reusable label + value pair for the detail screen.
// Extracted into its own struct so ArtworkDetailView's body stays clean.
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.body)
        }
        Divider()
    }
}
