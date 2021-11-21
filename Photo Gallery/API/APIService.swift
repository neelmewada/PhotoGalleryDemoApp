

import UIKit

/// Handles API requests.
/// Uses https://jsonplaceholder.typicode.com for placeholder JSON data.
final class APIService {
    
    public static let albumsUrl = "https://jsonplaceholder.typicode.com/albums"
    
    public static let photosUrl = "https://jsonplaceholder.typicode.com/photos"
    
    /// Fetches all the albums from the JSON placeholder API.
    /// - Parameter completion: The completion handler that is called on success or failure.
    public static func fetchAllAlbums(_ completion: @escaping ([AlbumInfo], Error?) -> ()) {
        guard let url = URL(string: albumsUrl) else {
            completion([], APIServiceError.invalidUrl)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            
            guard let data = data else { return }
            guard let response = response else { return }
            
            guard let albums = try? JSONDecoder().decode([AlbumInfo].self, from: data) else {
                DispatchQueue.main.async {
                    completion([], APIServiceError.decodeError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(albums, nil)
            }
        }
        
        task.resume()
    }
    
    /// Fetches all photos from the JSON placeholder API.
    /// - Parameter completion: The completion handler that is called on success or failure.
    public static func fetchAllPhotos(_ completion: @escaping ([PhotoInfo], Error?) -> ()) {
        guard let url = URL(string: photosUrl) else {
            completion([], APIServiceError.invalidUrl)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            
            guard let data = data else { return }
            guard let response = response else { return }
            
            guard let photos = try? JSONDecoder().decode([PhotoInfo].self, from: data) else {
                DispatchQueue.main.async {
                    completion([], APIServiceError.decodeError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(photos, nil)
            }
        }
        
        task.resume()
    }
    
    /// Fetches all the photos with the given album ID from the JSON placeholder API.
    /// - Parameters:
    ///   - albumId: The Id of the album to fetch the photos from.
    ///   - completion: The completion handler that is called on success or failure.
    public static func fetchAllPhotos(inAlbum albumId: Int, _ completion: @escaping ([PhotoInfo], Error?) -> ()) {
        guard let url = URL(string: "\(albumsUrl)/\(albumId)/photos") else {
            completion([], APIServiceError.invalidUrl)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            
            guard let data = data else { return }
            guard let response = response else { return }
            
            guard let photos = try? JSONDecoder().decode([PhotoInfo].self, from: data) else {
                DispatchQueue.main.async {
                    completion([], APIServiceError.decodeError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(photos, nil)
            }
        }
        
        task.resume()
    }
}

public enum APIServiceError: Error {
    case invalidUrl
    case decodeError
}
