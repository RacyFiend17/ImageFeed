import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let welcomeDescription: String?
    let urlsResult: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, width, height
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case urlsResult = "urls"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let regular: String
}
