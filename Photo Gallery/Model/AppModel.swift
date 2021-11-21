//
//  AppModel.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import UIKit

/// The main model class for the whole app.
final class AppModel: NSObject {
    // MARK: - Lifecycle
    
    private static var _shared: AppModel? = nil
    
    public static var shared: AppModel {
        if _shared == nil {
            _shared = AppModel()
        }
        return _shared!
    }
    
    private override init() {
        super.init()
        loadInitialData()
    }
    
    /// Call this function to explicitly initialize the AppModel singleton at app-launch.
    public static func initShared() {
        let _ = Self.shared
    }
    
    /// The event that's fired when `this` model's state has changed.
    private let modelChangeEvent: Event = Event()
    
    /// Lets all subscibers (aka ViewModels) know that model has changed.
    private func modelDidChange() {
        modelChangeEvent.raiseEvent()
    }
    
    // MARK: - Initializaton
    
    private func loadInitialData() {
        loadAlbums()
        loadPhotos()
    }
    
    /// Use this function to add a subscriber to receive notification when model updates.
    func subscribeForModelChanges(_ handler: @escaping Event.EventHandler) {
        self.modelChangeEvent.addSubscriber(handler)
    }
    
    // MARK: - Methods
    
    /// Loads all albums from the JSON placeholder API.
    private func loadAlbums() {
        APIService.fetchAllAlbums { albums, error in
            if let error = error {
                print("Error fetching albums. \(error)")
                return
            }
            
            self.albums = albums
            
            self.modelDidChange() // Notify the model changes
        }
    }
    
    /// Loads all photos from JSON API.
    private func loadPhotos() {
        self.photosPerAlbum.removeAll()
        
        APIService.fetchAllPhotos { photos, error in
            if let error = error {
                print("Error fetching photos in Album 1. \(error)")
                return
            }
            
            for photo in photos {
                self.photos[photo.id] = photo
                if self.photosPerAlbum[photo.albumId] == nil {
                    self.photosPerAlbum[photo.albumId] = []
                }
                self.photosPerAlbum[photo.albumId]?.append(photo)
            }
            
            self.modelDidChange() // Notify the model changes
        }
    }
    
    // MARK: - ViewModel Interface
    
    // ViewModel Interface: The properties & methods that are meant to be used by ViewModels.
    
    /// Collection of all albums from JSON API.
    public private(set) var albums = [AlbumInfo]()
    
    
    /// Cached Photo results from JSON API.
    /// Dictionary format: [id: PhotoInfo]  where id is PhotoInfo.id
    public private(set) var photos = [Int: PhotoInfo]()
    
    
    /// Collection of photos based on albumId.
    /// Dictionary format: [albumId: [PhotoInfo]]
    public private(set) var photosPerAlbum = [Int: [PhotoInfo]]()
    
}


