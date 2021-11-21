//
//  Album.swift
//  Photo-Learn
//
//  Created by Neel Mewada on 14/05/21.
//

import UIKit

/// Struct representing an Album in https://jsonplaceholder.typicode.com
public struct AlbumInfo: Codable {
    var userId: Int
    var id: Int
    var title: String
}
