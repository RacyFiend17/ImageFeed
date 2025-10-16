import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private var task: URLSessionTask? = nil
    private var lastCode: String? = nil
    private let tokenStorage = OAuth2TokenStorage.shared
    private init() {}
    
    func cleanToken() {
        tokenStorage.token = nil
    }
    
    private func makeOAuthTokenRequest (code: String) -> URLRequest? {
        guard var components = URLComponents(string: Constants.getTokenBaseURL) else { return nil }
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch result {
            case .success(let response):
                let token = response.accessToken
                self?.tokenStorage.token = token
                completion(.success(token))
                
            case .failure(let error):
                print("[fetchOAuthToken]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
