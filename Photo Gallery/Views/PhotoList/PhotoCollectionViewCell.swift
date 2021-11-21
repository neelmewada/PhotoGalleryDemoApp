
import UIKit

/// Represents a single Photo view cell in PhotoCollectionViewController.collectionView
class PhotoCollectionViewCell: UICollectionViewCell {
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
    
    /// The main image view that displays the thumbnail.
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private var imageUrl: String = ""
    
    // MARK: - Configuration
    
    /// Configure the UI of this cell. Called only once on init.
    private func configureCell() {
        addSubview(imageView)
        imageView.fillSuperview() // Set constraints to fill the superview
    }
    
    /// Configure or reload the data represented by this cell.
    func configureData(thumbnailUrl: String?) {
        guard let thumbnailUrl = thumbnailUrl else {
            print("Empty Thumbnail URL for a PhotoCollectionViewCell.")
            return
        }
        
        imageView.image = nil
        self.imageUrl = thumbnailUrl
        
        ImageCache.getImage(fromRemoteUrl: thumbnailUrl) { [weak self] image, url in
            guard let self = self else { return }
            if self.imageUrl == url {
                self.imageView.image = image
            }
        }
    }
}
