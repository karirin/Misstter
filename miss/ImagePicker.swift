//
//  ImagePicker.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/23.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    
    private var cache: NSCache<NSString, UIImage> = NSCache()
    
    func add(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let url: URL
    private let cache: ImageCache
    
    init(url: URL, cache: ImageCache) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        if let image = cache.image(for: url) {
            self.image = image
        } else {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                    self.cache.add(image, for: self.url)
                }
            }.resume()
        }
    }
}

struct CachedImage: View {
    @StateObject private var loader: ImageLoader
    
    init(url: URL) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: ImageCache.shared))
    }
    
    var body: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // or .fill

            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loader.load)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var image: UIImage?

        init(presentationMode: Binding<PresentationMode>, image: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = uiImage
            presentationMode.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
