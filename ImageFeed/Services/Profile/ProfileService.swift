import Foundation

final class ProfileService {
    
    private var task: URLSessionTask?
    private var session: URLSession = .shared
    static let shared = ProfileService()
    private(set) var profile: Profile?
    
    private init() {}
    
    func cleanProfile() {
        profile = nil
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURL)" + "/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String?, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let token else { completion(.failure(FetchProfileErrors.tokenError("Token is nil"))); return }
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name:  profileResult.firstName + " " + profileResult.lastName,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio)
                self?.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                print("[fetchProfile]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}
