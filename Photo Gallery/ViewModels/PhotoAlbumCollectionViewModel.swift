
import UIKit

/// ViewModel class for PhotoAlbumCollectionView.
class PhotoAlbumCollectionViewModel: ViewModel {
    // MARK: - Lifecycle
    
    init() {
        getDataFromModel()
        AppModel.shared.subscribeForModelChanges(self.getDataFromModel)
    }
    
    /// Gets the data from the Model.
    private func getDataFromModel() {
        self.albumsToDisplay = AppModel.shared.albums
        state = ViewState(albumsToDisplay: self.albumsToDisplay)
    }
    
    // MARK: - State Management
    
    typealias ViewState = PhotoAlbumCollectionViewController.ViewState
    
    private var renderCallback: RenderStateCallback?
    
    public func setRenderCallback(_ renderCallback: @escaping RenderStateCallback) {
        self.renderCallback = renderCallback
        // Make a callback once to initialize view's state
        self.renderCallback?(state)
    }
    
    /// The state represented by the View.
    public private(set) var state: ViewState = .empty {
        didSet {
            self.renderCallback?(state)
        }
    }
    
    // MARK: - Properties
    
    private var albumsToDisplay = [AlbumInfo]()
    
    // MARK: - Commands
    
    // Commands are called by the View
    
    /// Returns the thumbnail URL of the first photo in the album.
    /// - Parameter albumId: The album Id.
    /// - Returns: Returns the thumbnail URL if it exists, or nil if it doesn't.
    public func getThumbnailUrl(forAlbum albumId: Int) -> String? {
        guard let firstPhotoInAlbum = AppModel.shared.photosPerAlbum[albumId]?.first else {
            return nil
        }
        return AppModel.shared.photosPerAlbum[firstPhotoInAlbum.albumId]?.first?.thumbnailUrl
    }
    
    
    /// Returns the number of photos in the album with given albumId.
    public func getNumberOfPhotos(inAlbum albumId: Int) -> Int {
        return AppModel.shared.photosPerAlbum[albumId]?.count ?? 0
    }
}
