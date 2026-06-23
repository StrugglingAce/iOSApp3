//
//  ContentView.swift
//  iOSApp3
//
//  Created by Chibuzor Emmanuel Awanye on 2026-06-20.
//

import SwiftUI

// The root view handles search + navigation.
struct ContentView: View {

    // @State creates the ViewModel once and keeps it alive for the session
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.artworks.isEmpty {
                    emptyState
                } else {
                    resultsList
                }
            }
            .navigationTitle("Art Institute of Chicago")
            .navigationBarTitleDisplayMode(.large)
            // .searchable adds a native iOS search bar to the navigation bar
            .searchable(text: $viewModel.searchText, prompt: "Search artworks, artists...")
            // .onSubmit fires when the user taps the Search key on the keyboard
            .onSubmit(of: .search) {
                Task { await viewModel.searchArtworks() }
            }
            // Loading spinner shown over the list while a request is running
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Searching collection...")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            // Error alert shown when errorMessage is non-nil
            .alert("Something went wrong", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // Shown before a search is run and when results are empty
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "Search the Collection" : "No Results Found")
                .font(.title2)
                .bold()

            Text(viewModel.searchText.isEmpty
                 ? "Explore over 80,000 artworks from one of the world's premier art museums."
                 : "Try a different artist name, title, or keyword.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .padding()
    }

    // The scrollable list of artworks from the last search
    private var resultsList: some View {
        List(viewModel.artworks) { artwork in
            // Tapping a row pushes ArtworkDetailView onto the NavigationStack
            NavigationLink(destination: ArtworkDetailView(artwork: artwork, viewModel: viewModel)) {
                ArtworkRowView(artwork: artwork)
            }
        }
        .listStyle(.plain)
    }
}

#Preview { ContentView() }
