import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private var task: URLSessionTask? = nil
    private var lastCode: String? = nil
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
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
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    self?.tokenStorage.token = token
                    
                    completion(.success(token))
                    
                } catch {
                    print("Ошибка декодинга: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                
                if let netErr = error as? NetworkError {
                    switch netErr {
                    case .httpStatusCode(let code):
                        print("Unsplash вернул HTTP статус: \(code)")
                    case .urlRequestError(let underlying):
                        print("Ошибка URLRequest: \(underlying)")
                    case .urlSessionError:
                        print("Неизвестная ошибка URLSession")
                    case .invalidRequest:
                        print("Некорректный запрос (invalidRequest)")
                    case .decodingError(let underlying):
                        print("Ошибка декодера: \(underlying)")
                    }
                } else {
                    print("Запрос завершился с ошибкой: \(error)")
                }
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
