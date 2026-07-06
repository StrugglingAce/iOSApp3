//
//  ArticImageView.swift
//  iOSApp3
//

import SwiftUI

// Loads ARTIC IIIF images with the headers needed to avoid server-side challenge pages.
struct ArticImageView<Content: View, Placeholder: View, Failure: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    let failure: () -> Failure

    @State private var loadedImage: UIImage?
    @State private var didFail = false

    var body: some View {
        Group {
            if let loadedImage {
                content(Image(uiImage: loadedImage))
            } else if didFail || url == nil {
                failure()
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        loadedImage = nil
        didFail = false

        guard let url else {
            didFail = true
            return
        }

        var request = URLRequest(url: url)
        request.setValue("https://www.artic.edu/", forHTTPHeaderField: "Referer")
        request.setValue("iOSApp3 (local development)", forHTTPHeaderField: "AIC-User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let image = UIImage(data: data)
            else {
                didFail = true
                return
            }

            loadedImage = image
        } catch {
            didFail = true
        }
    }
}
