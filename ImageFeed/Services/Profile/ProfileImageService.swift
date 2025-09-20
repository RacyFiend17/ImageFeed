struct ProfileImage: Decodable {
    let small: String?
    let medium: String?
    let large: String?
}

struct UserResult: Decodable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

enum ProfileImageError: Error {
    case invalidURL
    case decodingFailed
}

final class ProfileImageService {
    private func fetchProfileImage(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        
    }
}
