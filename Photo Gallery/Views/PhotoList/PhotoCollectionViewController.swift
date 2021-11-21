//
//  PhotoListViewController.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import UIKit

/// Displays a Collection of all Photos present in the given album.
class PhotoCollectionViewController: UIViewController {
    // MARK: - Lifecycle
    
    /// Initializes the PhotoCollectionViewController with the given albumId.
    init(albumId: Int) {
        self.albumId = albumId
        self.viewModel = PhotoCollectionViewModel(albumId: albumId)
        
        let screenWidth = UIScreen.main.bounds.width
        //let screenHeight = UIScreen.main.bounds.height
        
        let width = screenWidth / 3 - 5
        let height = width
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        
        // Set a render callback for view model
        // It also calls the render method once.
        self.viewModel.setRenderCallback { [weak self] newState in
            self?.render(state: newState)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Properties
    
    public let albumId: Int
    
    private let viewModel: PhotoCollectionViewModel
    
    private let collectionView: UICollectionView
    
    private static let reuseId = "cell"
    
    private var interactionEnabled = true
    
    /// The photo collection cell that was tapped
    private var openedPhotoDetailCell: PhotoCollectionViewCell? = nil
    
    /// The photo detail view controller that is currently opened as a child to root naviation controller
    private var openedPhotoDetailVC: PhotoDetailViewController? = nil
    
    /// The photos displayed in the collection view
    private var photosToDisplay = [PhotoInfo]()
    
    // MARK: - Configuration
    
    /// Configures the View Controller once on init.
    private func configureViewController() {
        navigationItem.title = "Photos"
        view.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Methods
    
    /// Opens a tapped photo in PhotoDetailView if interaction is enabled.
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if !interactionEnabled {
            return
        }
        
        let point = recognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else { return }
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
        self.openedPhotoDetailCell = cell
        
        if self.openedPhotoDetailVC != nil {
            self.openedPhotoDetailVC?.removeFromParent()
            self.openedPhotoDetailVC = nil
        }
        
        let photoFrame = navigationController!.view.convert(cell.frame, from: collectionView)
        
        self.openedPhotoDetailVC = PhotoDetailViewController(photo: photosToDisplay[indexPath.item], photoFrame: photoFrame, initialImage: cell.imageView.image, delegate: self)
        
        // Add Photo Detail View Controller as a child to the root navigation controller
        navigationController!.view.addSubview(openedPhotoDetailVC!.view)
        navigationController!.addChild(openedPhotoDetailVC!)
        self.openedPhotoDetailVC?.didMove(toParent: navigationController!)
    }
}

// MARK: - State Management

extension PhotoCollectionViewController {
    
    /// The struct that represents the state of this view.
    public struct ViewState {
        var photos: [PhotoInfo]
        
        static var empty: ViewState {
            return ViewState(photos: [])
        }
    }
    
    /// Renders the given state for this view. Called by ViewModel.
    public func render(state: ViewState) {
        self.photosToDisplay = state.photos
        collectionView.reloadData()
    }
}


// MARK: - PhotoDetailViewDelegate

extension PhotoCollectionViewController: PhotoDetailViewControllerDelegate {
    
    // Enable Navigations's swipe-to-pop gesture when photo detail view controller will dismiss
    func photoDetailVCWillDismiss(_ photoDetailViewController: PhotoDetailViewController) {
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
    }
    
    func photoDetailVCDidDismiss(_ photoDetailViewController: PhotoDetailViewController) {
        // Remove Photo Detail View Controller from the root navigation controller's child hierarchy
        self.openedPhotoDetailVC?.willMove(toParent: nil)
        self.openedPhotoDetailVC?.removeFromParent()
        self.openedPhotoDetailVC?.view.removeFromSuperview()
        
        self.openedPhotoDetailCell?.imageView.alpha = 1
        self.openedPhotoDetailCell = nil
    }
    
    // Disable Navigations's swipe-to-pop gesture when photo detail view controller will appear
    func photoDetailVCWillAppear(_ photoDetailViewController: PhotoDetailViewController) {
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        self.openedPhotoDetailCell?.imageView.alpha = 0
    }
}


// MARK: - UICollectionViewDataSource

extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseId, for: indexPath) as! PhotoCollectionViewCell
        let cellIndex = indexPath.item
        let photoInfo = photosToDisplay[cellIndex]
        
        // Configure the Cell to show the thumbnail image
        let thumbnailUrl = photoInfo.thumbnailUrl
        cell.configureData(thumbnailUrl: thumbnailUrl)
        return cell
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 5
        let height = width
        return CGSize(width: width, height: height)
    }
    
}
