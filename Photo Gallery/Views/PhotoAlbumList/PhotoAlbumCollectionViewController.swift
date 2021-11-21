//
//  PhotoAlbumCollectionView.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import UIKit

/// The Album Collection View that is displayed in the HomeViewController
class PhotoAlbumCollectionViewController: UICollectionViewController {
    // MARK: - Lifecycle
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 170, height: 210)
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumLineSpacing = 30
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        self.configureViewController()
        
        // Set a render callback for view model
        // It also calls the render method once.
        self.viewModel.setRenderCallback { [weak self] newState in
            self?.render(state: newState)
        }
    }
    
    // MARK: - Properties
    
    private let viewModel = PhotoAlbumCollectionViewModel()
    
    private static let reuseId = "cell"
    
    private var albumsToDisplay = [AlbumInfo]()
    
    // MARK: - Configuration
    
    /// Configure the collection view once on init.
    private func configureViewController() {
        navigationItem.title = "Albums"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        navigationItem.searchController = UISearchController()
        
        view.backgroundColor = .systemBackground
        self.collectionView.backgroundColor = .systemBackground
        
        self.collectionView.register(PhotoAlbumCollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseId)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.collectionView.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Actions
    
    @objc private func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: self.collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        guard let tappedCell = collectionView.cellForItem(at: indexPath) as? PhotoAlbumCollectionViewCell else { return }
        
        let photoListVC = PhotoCollectionViewController(albumId: tappedCell.albumId)
        navigationController?.pushViewController(photoListVC, animated: true)
    }
}

// MARK: - State Management

extension PhotoAlbumCollectionViewController {
    
    /// The struct that represents the state of this view.
    public struct ViewState {
        var albumsToDisplay: [AlbumInfo]
        
        static var empty: ViewState {
            return ViewState(albumsToDisplay: [])
        }
    }
    
    /// Renders the given state for this view. Called by ViewModel
    public func render(state: ViewState) {
        self.albumsToDisplay = state.albumsToDisplay
        
        print("Render state called with array count: \(state.albumsToDisplay.count)")
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoAlbumCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsToDisplay.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseId, for: indexPath) as! PhotoAlbumCollectionViewCell
        let cellIndex = indexPath.item
        let album = albumsToDisplay[cellIndex]
        let numberOfPhotosInAlbum = viewModel.getNumberOfPhotos(inAlbum: album.id)
        
        guard let thumbnailUrl = viewModel.getThumbnailUrl(forAlbum: album.id) else { return cell }
        cell.configureData(thumbnailUrl: thumbnailUrl, albumId: album.id, title: album.title, count: numberOfPhotosInAlbum)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoAlbumCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 210)
    }
}
