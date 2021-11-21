//
//  ViewModel.swift
//  Photo Gallery
//
//  Created by Neel Mewada on 15/05/21.
//

import Foundation

/// The protocol that all view model classes conform to.
public protocol ViewModel: AnyObject {
    associatedtype ViewState
    
    typealias RenderStateCallback = (ViewState) -> ()
    
    /// Use this function to enable View Model class to make render callbacks.
    func setRenderCallback(_ renderCallback: @escaping RenderStateCallback)
}
