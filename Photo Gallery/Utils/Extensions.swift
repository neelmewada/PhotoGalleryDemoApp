
import Foundation
import UIKit

// This file contains all helper extensions

// MARK: - UIView

extension UIView {
    
    /// Returns the original frame by removing the transform and applying it back again.
    var originalFrame: CGRect {
        let origTransform = self.transform
        self.transform = .identity
        let origFrame = self.frame
        self.transform = origTransform
        return origFrame
    }
    
    /// Sets up all the constraints with the corresponding supplied anchors (non-nil values) and spacings
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                spacingTop: CGFloat = 0,
                spacingLeft: CGFloat = 0,
                spacingBottom: CGFloat = 0,
                spacingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: spacingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: spacingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -spacingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -spacingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    /// Centers `this` view in it's superview.
    func centerInSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            center(inView: superview)
        }
    }
    
    /// Center the view horizontally and vertically with an optional vertical offset with respect to `inView`
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    /// Center the view horizontally with respect to `inView`
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, spacingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: spacingTop!).isActive = true
        }
    }
    
    /// Center the view vertically with respect to `inView`
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 spacingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, spacingLeft: spacingLeft)
        }
    }
    
    /// Set width and height constraints
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(minHeight: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
    }
    
    func setHeight(maxHeight: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(minWidth: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth).isActive = true
    }
    
    func setWidth(maxWidth: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    /// Modifies top, left, bottom and right anchor constraints to fill the superview perfectly.
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    /// Make this view fill the entire superview according to the safeAreaLayoutGuide. It modifies top, left, bottom and right anchor constraints.
    func fillSuperviewSafe() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
               bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
}

// MARK: - UIColor

extension UIColor {
    public static func fromHex(_ hex: String) -> UIColor {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        return UIColor(
            red:   CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - UIApplication

extension UIApplication {
    public func getKeyWindow() -> UIWindow? {
        for window in windows {
            if window.isKeyWindow {
                return window
            }
        }
        return nil
    }
}
