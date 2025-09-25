import Foundation

struct ProfileImage: Decodable {
    let small: String?
    let medium: String?
    let large: String?
}

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

enum ProfileImageError: Error {
    case invalidURL
    case decodingFailed
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private var session: URLSession = .shared
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "didChangeNotification")
    private init() {}
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURL)" + "/users/:\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(FetchProfileErrors.tokenError("Token is nil")))
            return
        }
        task?.cancel()
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = session.data(for: request) { [weak self] result in
            switch result {
                case .success(let data):
                guard let self else { return }
                do {
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    guard let avatarURL = userResult.profileImage.small else {
                        return
                    }
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                }
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                    return
                }
                case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }

}
