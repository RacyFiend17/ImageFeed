import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fullFillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fullFillCompletionOnMainThread(.success(data))
                } else {
                    print("HTTP error status code: \(statusCode)")
                    fullFillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("URL request error: \(error)")
                fullFillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("URLSession error: \(String(describing: error))")
                fullFillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        return task as URLSessionTask
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученные данные: \(jsonString)")
                }
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("Ошибка декодирования: \(decodingError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    } else {
                        print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    completion(.failure((error)))
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
                        print("Некорректный запрос")
                    case .decodingError(let underlying):
                        print("Ошибка декодера: \(underlying)")
                    }
                } else {
                    print("Запрос завершился с ошибкой: \(error.localizedDescription)")
                }
                completion(.failure(error))
            }
        }
        return task
    }
}

