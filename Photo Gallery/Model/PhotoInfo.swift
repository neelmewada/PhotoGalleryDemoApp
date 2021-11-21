//
//  PhotoInfo.swift
//  Photo-Learn
//
//

import UIKit

/// Struct representing a Photo in https://jsonplaceholder.typicode.com
public struct PhotoInfo: Codable {
    var albumId: Int
    var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
    
    
    public static var empty: PhotoInfo {
        return PhotoInfo(albumId: 0, id: 0, title: "", url: "", thumbnailUrl: "")
    }
}
