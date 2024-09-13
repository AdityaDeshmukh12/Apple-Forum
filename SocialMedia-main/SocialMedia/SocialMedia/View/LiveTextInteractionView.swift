//
//  LiveTextInteractionView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 16/04/23.
//

import SwiftUI
import VisionKit
import SDWebImage

struct LiveTextInteractionView: View {
    
    var post: Post
    @Environment (\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            if let postImageURL = post.imageURL {
                LiveTextInteraction(imageName: postImageURL)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .interactiveDismissDisabled(true)
            }
            else {
                Text("NO Image")
            }
        }
    }
}

//struct LiveTextInteractionView_Previews: PreviewProvider {
//    static var previews: some View {
//        LiveTextInteractionView(imageName: URL(string: "")!)
//    }
//}
@MainActor
struct LiveTextInteraction: UIViewRepresentable {
    
    var imageName: URL
    let imageView = LiveTextImageView()
    let interaction = ImageAnalysisInteraction()
    let analyzer = ImageAnalyzer()
    
    func makeUIView(context: Context) -> some UIView {
        //imageView.image=UIImage(named: "testImage")
        loadData(url: imageName) { data, error in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
            }
        }
        
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            let configuration = ImageAnalyzer.Configuration([.text,.machineReadableCode])
            do {
                if let image = imageView.image {
                    let analysis = try await analyzer.analyze(image, configuration: configuration)
                    
                    interaction.analysis = analysis;
                    interaction.preferredInteractionTypes = .automatic
                }
            }
            catch {
                print("error:\(error)")
            }
        }
    }
    
    func loadData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        // Compute a path to the URL in the cache
        let fileCachePath = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                url.lastPathComponent,
                isDirectory: false
            )
        print(fileCachePath.absoluteString)
        // If the image exists in the cache,
        // load the image from the cache and exit
        do {
            let data = try Data(contentsOf: fileCachePath)
            completion(data, nil)
            return
        }
        catch {
            print("error in loaddata:\(error)")
            print(error)
        }
        // If the image does not exist in the cache,
        // download the image to the cache
        download(url: url, toFile: fileCachePath) { (error) in
            do {
                let data = try Data(contentsOf: fileCachePath)
                completion(data, error)
            }catch {
                print("error 34")
            }
            
        }
    }
    
    
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )

                completion(nil)
            }

            // Handle potential file system errors
            catch {
                print("error at download:\(error.localizedDescription)")
                completion(error)
            }
        }

        // Start the download
        task.resume()
    }
}

class LiveTextImageView: UIImageView {
    // Use intrinsicContentSize to change the default image size
    // so that we can change the size in our SwiftUI View
    override var intrinsicContentSize: CGSize {
        .zero
    }
}
