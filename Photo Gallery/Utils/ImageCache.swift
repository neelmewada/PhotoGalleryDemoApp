//
//  ImageCache.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 23/05/21.
//

import UIKit

/// Implements quick and simple image caching.
public final class ImageCache {
    
    /// Caches the given image to the disk.
    private static func cacheImage(remoteImageUrl: String, image: UIImage) {
        guard var cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        
        cacheUrl.appendPathComponent("ImageCache")
        
        if !FileManager.default.fileExists(atPath: cacheUrl.path) {
            try? FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let encodedUrl = remoteImageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        cacheUrl.appendPathComponent(encodedUrl)
        cacheUrl.appendPathExtension("png")
        
        guard let data = image.pngData() else { return }
        
        do {
            try data.write(to: cacheUrl)
        } catch {
            print("Error caching image with to \(cacheUrl.path)")
            print("Error: \(error)")
        }
    }
    
    
    /// Fetches and returns the image from the given remote url, or from the cache if it exists.
    /// - Parameters:
    ///   - url: The remote URL of the image.
    ///   - completion: The completion handler.
    public static func getImage(fromRemoteUrl url: String, _ completion: @escaping (UIImage?, String) -> ()) {
        guard let remoteUrl = URL(string: url) else { return }
        guard var cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        
        cacheUrl.appendPathComponent("ImageCache")
        
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        cacheUrl.appendPathComponent(encodedUrl)
        cacheUrl.appendPathExtension("png")
        
        if FileManager.default.fileExists(atPath: cacheUrl.path) {
            do {
                let imageData = try Data(contentsOf: cacheUrl)
                completion(UIImage(data: imageData), url)
            } catch {
                print("Error loading image. \(error)")
            }
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: remoteUrl) {
                if let image = UIImage(data: data) {
                    cacheImage(remoteImageUrl: url, image: image)
                    DispatchQueue.main.async {
                        completion(image, url)
                    }
                }
            }
        }
    }
}
