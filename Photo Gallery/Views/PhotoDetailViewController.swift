//
//  PhotoDetailViewController.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 21/05/21.
//

import UIKit


class PhotoDetailViewController: UIViewController {
    // MARK: - Lifecycle
    
    /// Initializes the PhotoDetailView with a photo and a photoFrame.
    /// - Parameters:
    ///   - photo: Information on the photo to be displayed by the detail view.
    ///   - photoFrame: The exact frame size of photo thumbnail view as in PhotoCollectionView. Used for animation purposes.
    ///   - initialImage: The image that is displayed initially. i.e. Pass the thumbail image here.
    ///   - delegate: A class that conforms to PhotoDetailViewDelegate.
    
    init(photo: PhotoInfo, photoFrame: CGRect, initialImage: UIImage? = nil, delegate: PhotoDetailViewControllerDelegate? = nil) {
        self.photo = photo
        self.photoFrame = photoFrame
        self.delegate = delegate
        self.imageView.image = initialImage
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    // MARK: - Properties
    
    private var photo: PhotoInfo
    private let photoFrame: CGRect
    
    public weak var delegate: PhotoDetailViewControllerDelegate? = nil
        
    /// The height for the popup description view.
    private var descriptionViewHeight: CGFloat {
        return descriptionLabel.intrinsicContentSize.height + 40
    }
    
    private var previousTranslation = CGPoint()
    private var currentPan = CGPoint()
    private var previousPan = CGPoint()
    
    private var isDescriptionShown = false
    private var currentPanMode: PanMode = .free
    
    // MARK: - Configuration
    
    private func configureViewController() {
        view.backgroundColor = .clear
        
        view.addSubview(gestureView)
        gestureView.fillSuperview()
        
        view.addSubview(imageView)
        //imageView.sd_setImage(with: URL(string: photo.thumbnailUrl))
        //self.imageView.sd_setImage(with: URL(string: self.photo.url), placeholderImage: self.imageView.image)
        
        ImageCache.getImage(fromRemoteUrl: self.photo.url) { [weak self] image, _ in
            guard let self = self else { return }
            self.imageView.image = image
        }
        
        imageView.frame = photoFrame
        
        view.addSubview(descriptionView)
        descriptionView.alpha = 0
        descriptionView.frame = CGRect(x: 0, y: photoFrame.origin.y + photoFrame.height + 100,
                                  width: photoFrame.width, height: descriptionViewHeight)
        
        view.addSubview(topBar)
        topBar.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 90)
        topBar.alpha = 0
        
        // Show animated on load
        showAnimated()
    }
    
    // MARK: - Actions
    
    @objc private func backButtonPressed() {
        hideAnimated()
    }
    
    /// Handles the rotation gesture functionality.
    @objc private func handleRotationGesture(_ rotationGesture: UIRotationGestureRecognizer) {
        if isDescriptionShown || currentPanMode == .verticalOnly {
            rotationGesture.state = .failed
            return
        }
        
        let rotation = rotationGesture.rotation
        if rotationGesture.state == .began || rotationGesture.state == .changed {
            self.imageView.transform = self.imageView.transform.rotated(by: rotation)
        }
        rotationGesture.rotation = 0
    }
    
    /// Handles the pinch gesture functionality.
    @objc private func handlePinchGesture(_ pinchGesture: UIPinchGestureRecognizer) {
        if isDescriptionShown || currentPanMode == .verticalOnly {
            pinchGesture.state = .failed
            return
        }
        
        let scale = pinchGesture.scale
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            self.imageView.transform = self.imageView.transform.scaledBy(x: scale, y: scale)
        }
        
        pinchGesture.scale = 1
    }
    
    /// Handles the pan gesture functionality.
    @objc private func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        // update the current pan distance
        currentPan.y += translation.y
        currentPan.x += translation.x
        
        // set pan mode to verticalOnly, if the finger moved upward
        if panGesture.state == .began {
            currentPanMode = (currentPan.y >= 0) ? .free : .verticalOnly
        }
        
        if panGesture.state == .began || panGesture.state == .changed {
            
            // disable X-axis translation if pan mode is either verticalOnly OR if descriptionView is visible
            let transX = (isDescriptionShown || currentPanMode == .verticalOnly) ? 0 : translation.x * 0.5
            
            self.imageView.transform = self.imageView.transform.translatedBy(x: transX, y: translation.y)
            
            // current pan distance is downwards & description is hidden in free pan mode
            if currentPan.y > 0 && !isDescriptionShown && currentPanMode == .free {
                
                // Lerp the alpha from 1 to 0 over a distance of 300 units
                let alpha = Math.lerp(from: 1, to: 0, t: currentPan.y / 300)
                setBackgroundAlpha(alpha)
                
            } else { // Handle verticalOnly pan mode
                
                setBackgroundAlpha(1)
                
                if currentPan.y < 0 {
                    // Description view will travel up ONLY if current Y-translation is greater than -250 units
                    let factor = Math.lerp(from: 0.05, to: 0.8, t: (currentPan.y + 250) / 250)
                    // The descriptionView Y-translation will decrease with `factor`
                    self.descriptionView.frame.origin.y += translation.y * factor
                } else {
                    self.descriptionView.frame.origin.y += translation.y
                }
                
            }
        }
        
        // Handle the pan gesture ended state
        if panGesture.state == .ended {
            
            if !isDescriptionShown { // if description view is hidden
                
                // hide if pan ended with a downward swipe in free pan mode, & current translation dist Y > 0
                if previousTranslation.y > 0.5 && currentPan.y > 0 && currentPanMode == .free {
                    hideAnimated()
                } else if currentPanMode == .free { // pan ended with upward swipe in free pan mode
                    
                    // If final Y-translation is 100 or more in downward direction
                    if currentPan.y >= 100 {
                        hideAnimated()
                    } else {
                        animateToDefaultPosition()
                    }
                    
                } else if currentPanMode == .verticalOnly { // handle end-state for verticalOnly pan mode
                    
                    // If final Y-translation is above the initial position (upward)
                    if currentPan.y < 0 {
                        showDescriptionView()
                    } else {
                        animateToDefaultPosition()
                    }
                    
                }
                
            } else { // if description view is shown
                
                if currentPan.y > 10 { // if total translation is more than 10 downwards, then hide description view
                    hideDescriptionView()
                } else {
                    animateToDescriptionView()
                }
            }
            
            // Reset the variables on pan end
            currentPan.y = 0
            currentPan.x = 0
            currentPanMode = .free
        }
        
        previousPan = currentPan
        previousTranslation = translation
        panGesture.setTranslation(.zero, in: self.view) // Set translation to zero so we get delta of translation on every call.
    }
    
    // MARK: - Methods
    
    /// Helper function to set background & topBar's alpha value
    private func setBackgroundAlpha(_ alpha: CGFloat) {
        self.view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
        self.topBar.subviews[0].alpha = alpha
    }
    
    /// Shows the description view with the image description right below the image. Animated.
    public func showDescriptionView() {
        if isDescriptionShown {
            return
        }
        
        isDescriptionShown = true
        animateToDescriptionView()
    }
    
    /// Hides the description view. Animated.
    public func hideDescriptionView() {
        if !isDescriptionShown {
            return
        }
        
        isDescriptionShown = false
        animateToDefaultPosition()
    }
    
    /// Animates the current state to show the description view.
    private func animateToDescriptionView() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the final frame size for the image view. The image will be 90 pts upward to show the description view
        let photoFrameAspectRatio = photoFrame.width / photoFrame.height
        let finalImageWidth = screenWidth
        let finalImageHeight = finalImageWidth / photoFrameAspectRatio
        let finalFrame = CGRect(x: 0, y: screenHeight / 2 - finalImageHeight / 2 - 90, width: finalImageWidth, height: finalImageHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseOut]) {
            // Move the image view 90 pts upwards
            self.imageView.transform = .identity
            self.imageView.frame = finalFrame
            self.view.backgroundColor = .systemBackground
            
            // Show the description view directly below the image
            self.descriptionView.alpha = 1
            self.descriptionView.frame = CGRect(x: 0, y: finalFrame.origin.y + finalFrame.height,
                                                width: finalFrame.width, height: self.descriptionViewHeight)
        }
    }
    
    /// Animates everything back to the default position, i.e. Image is centered and description view is hidden.
    private func animateToDefaultPosition() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the final frame size for the image view
        let photoFrameAspectRatio = photoFrame.width / photoFrame.height
        let finalImageWidth = screenWidth
        let finalImageHeight = finalImageWidth / photoFrameAspectRatio
        let finalFrame = CGRect(x: 0, y: screenHeight / 2 - finalImageHeight / 2, width: finalImageWidth, height: finalImageHeight)
        
        // Bring image view to it's default position
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.3, options: [.curveEaseIn]) {
            self.imageView.transform = .identity
            self.imageView.frame = finalFrame
            self.view.backgroundColor = .systemBackground
        }
        
        // Make sure that description view is hidden
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.descriptionView.alpha = 0
            self.descriptionView.frame = CGRect(x: 0, y: finalFrame.origin.y + finalFrame.height + 70,
                                                width: finalFrame.width,
                                                height: self.descriptionViewHeight)
        }
    }
    
    /// Shows the PhotoDetailView. Animated.
    public func showAnimated() {
        self.view.isHidden = false
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.delegate?.photoDetailVCWillAppear?(self)
        
        // Calculate the final frame size for the image view
        let photoFrameAspectRatio = photoFrame.width / photoFrame.height
        let finalImageWidth = screenWidth
        let finalImageHeight = finalImageWidth / photoFrameAspectRatio
        let finalFrame = CGRect(x: 0, y: screenHeight / 2 - finalImageHeight / 2, width: finalImageWidth, height: finalImageHeight)
        
        // Set the description view to it's hidden state with 100 pts offset downard
        descriptionView.alpha = 0
        descriptionView.frame = CGRect(x: 0, y: finalFrame.origin.y + finalFrame.height + 100,
                                  width: finalFrame.width, height: descriptionViewHeight)
        
        // Show the image view with spring animation
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.2, options: [.curveEaseInOut]) {
            self.imageView.transform = .identity
            self.imageView.frame = finalFrame
        } completion: { _ in
            self.delegate?.photoDetailVCDidAppear?(self)
        }
        
        // Show the topBar and background color with normal animation
        UIView.animate(withDuration: 0.5) {
            self.topBar.alpha = 1.0
            self.view.backgroundColor = .systemBackground
        }
    }
    
    
    /// Hides the PhotoDetailView. Animated.
    /// - Parameter velocity: The initial spring velocity used for animation.
    public func hideAnimated(_ velocity: CGFloat = 0.2) {
        self.delegate?.photoDetailVCWillDismiss?(self)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the final frame size for the image view
        let photoFrameAspectRatio = photoFrame.width / photoFrame.height
        let finalImageWidth = screenWidth
        let finalImageHeight = finalImageWidth / photoFrameAspectRatio
        let finalFrame = CGRect(x: 0, y: screenHeight / 2 - finalImageHeight / 2, width: finalImageWidth, height: finalImageHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: velocity) {
            // Hide the image view and topBar
            self.imageView.transform = .identity
            self.imageView.frame = self.photoFrame
            self.view.backgroundColor = .clear
            self.topBar.alpha = 0
            
            // Make sure description view is hidden
            self.descriptionView.alpha = 0
            self.descriptionView.frame = CGRect(x: 0, y: finalFrame.origin.y + finalFrame.height + 100,
                                                width: finalFrame.width, height: self.descriptionViewHeight)
            
        } completion: { _ in
            self.view.isHidden = true
            self.delegate?.photoDetailVCDidDismiss?(self)
        }
    }
    
    // MARK: - Views
    
    /// The main Image View that displays the full-size image.
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// The view that recognizes all the gestures.
    private lazy var gestureView: UIView = {
        let view = UIView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        rotationGesture.delegate = self
        view.addGestureRecognizer(rotationGesture)
        
        view.backgroundColor = .clear
        return view
    }()
    
    /// The title label that is added to the topBar.
    private lazy var barTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Photo Preview"
        return label
    }()
    
    /// The back button that is added in topBar.
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.imageView?.centerInSuperview()
        button.imageView?.setDimensions(height: 24, width: 24)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return button
    }()
    
    /// The nav bar that appears at the top in Photo Detail View.
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 40)
        
        contentView.addSubview(barTitleLabel)
        barTitleLabel.centerX(inView: contentView)
        barTitleLabel.center(inView: contentView, yConstant: -5)
        let bottomLine = UIView()
        bottomLine.backgroundColor = .fromHex("DFE1E1")
        view.addSubview(bottomLine)
        bottomLine.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 1)
        
        contentView.addSubview(backButton)
        backButton.centerY(inView: contentView, constant: -5)
        backButton.anchor(left: contentView.leftAnchor, spacingLeft: 10, width: 24, height: 24)
        return view
    }()
    
    /// The description displayed when user swipes up the image.
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = photo.title
        label.numberOfLines = 2
        label.textColor = .systemGray3
        return label
    }()
    
    /// The description view that slides up and shows the descriptionLabel when user swipes up.
    private lazy var descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, spacingLeft: 20, spacingRight: 20)
        descriptionLabel.centerY(inView: view)
        return view
    }()
}

// MARK: - PhotoDetailViewControllerDelegate

@objc protocol PhotoDetailViewControllerDelegate {
    @objc optional func photoDetailVCWillDismiss(_ photoDetailViewController: PhotoDetailViewController)
    @objc optional func photoDetailVCDidDismiss(_ photoDetailViewController: PhotoDetailViewController)
    
    @objc optional func photoDetailVCWillAppear(_ photoDetailViewController: PhotoDetailViewController)
    @objc optional func photoDetailVCDidAppear(_ photoDetailViewController: PhotoDetailViewController)
}

// MARK: - UIGestureRecognizerDelegate

extension PhotoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer {
            return false
        }
        return true
    }
}

extension PhotoDetailViewController {
    /// Describes the current Pan Mode.
    public enum PanMode {
        /// Allow panning in all directions.
        case free
        
        /// Pan the image vertically only.
        case verticalOnly
    }
}
