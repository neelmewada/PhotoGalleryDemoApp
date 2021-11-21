//
//  PhotoAlbumCollectionViewCell.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import UIKit

/// The Collection View Cell that represents  a single album with a thumbnail, title and photo count.
class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        return layoutAttributes
    }
    
    // MARK: - Properties
    
    public private(set) var albumId = -1
    
    // MARK: - Configuration
    
    /// Configures the cell once on init. Use it to configure UI, add subviews, constraints, etc.
    private func configureCell() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, spacingBottom: 40)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, right: rightAnchor, spacingTop: 10)
        
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, spacingTop: 5)
    }
    
    /// Configure the data displayed by this cell.
    func configureData(thumbnailUrl: String?, albumId: Int, title: String, count: Int) {
        self.albumId = albumId
        
        guard let thumbnailUrl = thumbnailUrl else {
            print("Empty Thumbnail URL for album: \(albumId)")
            return
        }
        
        titleLabel.text = title
        subtitleLabel.text = "\(count)"
        
        imageView.image = nil
        
        ImageCache.getImage(fromRemoteUrl: thumbnailUrl) { [weak self] image, _ in
            guard let self = self else { return }
            self.imageView.image = image
        }
    }
    
    // MARK: - Views
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray
        return label
    }()
}
