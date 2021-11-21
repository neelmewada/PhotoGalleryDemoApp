

import UIKit

class RootNavigationController: UINavigationController {
    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
