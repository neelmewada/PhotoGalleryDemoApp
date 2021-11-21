
import UIKit

/// View Model class for PhotoCollectionViewController
class PhotoCollectionViewModel: ViewModel {
    // MARK: - Lifecycle
    
    init(albumId: Int) {
        self.albumId = albumId
        getDataFromModel()
        AppModel.shared.subscribeForModelChanges(self.getDataFromModel) // Reload data when model changes
    }
    
    /// Gets the required data from AppModel class
    private func getDataFromModel() {
        self.photosToDisplay = AppModel.shared.photosPerAlbum[albumId] ?? []
        state = ViewState(photos: self.photosToDisplay)
    }
    
    // MARK: - Properties
    
    private let albumId: Int
    
    // MARK: - State Management
    
    typealias ViewState = PhotoCollectionViewController.ViewState
    
    private var renderCallback: RenderStateCallback?
    
    public func setRenderCallback(_ renderCallback: @escaping RenderStateCallback) {
        self.renderCallback = renderCallback
        // Make a callback once to initialize view's state
        self.renderCallback?(state)
    }
    
    public private(set) var state: ViewState = .empty {
        didSet {
            self.renderCallback?(state)
        }
    }
    
    // MARK: - Properties
    
    /// The photos displayed by PhotoCollectionView.collectionView
    private var photosToDisplay = [PhotoInfo]()
}


