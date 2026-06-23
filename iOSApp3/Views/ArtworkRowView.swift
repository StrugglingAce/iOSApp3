//
//  ArtworkRowView.swift
//  iOSApp3
//
//  Created by Chibuzor Emmanuel Awanye on 2026-06-21.
//

import SwiftUI

// A single card in the search results list.
// Kept as its own struct to keep ContentView readable
struct ArtworkRowView: View {
    let artwork: Artwork

    var body: some View {
        HStack(spacing: 14) {

            // AsyncImage loads the thumbnail from ARTIC's IIIF server.
            // It handles the loading and error states internally.
            AsyncImage(url: artwork.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    // Shown while the image is downloading
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay { ProgressView() }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    // Shown if the image URL fails to load
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Artwork text info
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(2)

                if let artist = artwork.artistDisplay {
                    // artistDisplay often contains newlines
                    Text(artist.components(separatedBy: "\n").first ?? artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let date = artwork.dateDisplay {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
