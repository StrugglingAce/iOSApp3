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

            // ARTIC's image server expects request headers, so use our custom loader.
            ArticImageView(url: artwork.thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay { ProgressView() }
            } failure: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
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
