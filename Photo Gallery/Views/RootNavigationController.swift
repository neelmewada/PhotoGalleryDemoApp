//
//  RootNavigationController.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

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
