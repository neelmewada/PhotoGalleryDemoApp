
import UIKit

/// Struct representing an Album in https://jsonplaceholder.typicode.com
public struct AlbumInfo: Codable {
    var userId: Int
    var id: Int
    var title: String
}
