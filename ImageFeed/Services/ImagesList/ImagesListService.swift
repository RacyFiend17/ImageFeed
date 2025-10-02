import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init () {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    private var session: URLSession = .shared
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    } ()
    
    private func makeImagesListRequest(token: String, nextPage: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURL)" + "/photos") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        if task != nil {
            print("ImagesListService: fetchPhotosNextPage: request is already in progress")
            return }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion((.failure(FetchProfileErrors.tokenError("Token is nil"))))
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeImagesListRequest(token: token, nextPage: nextPage) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer {
                self.task = nil
            }
            
            switch result {
            case .success(let photoResultArray):
                
                for photoResult in photoResultArray{
                    var date: Date? = nil
                    if photoResult.createdAt != nil {
                        let formatter = ISO8601DateFormatter()
                        date = formatter.date(from: photoResult.createdAt!)
                    }
                    
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: date,
                        welcomeDescription: photoResult.welcomeDescription,
                        thumbImageURL: photoResult.urlsResult.thumb,
                        largeImageURL: photoResult.urlsResult.regular,
                        isLiked: photoResult.likedByUser)
                    
                    self.photos.append(photo)
                }
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["PhotosArray": photos, "lastLoadedPage": nextPage])
                
                self.lastLoadedPage? = nextPage
                
                completion(.success(self.photos))
            case .failure(let error):
                print("[fetchPhotosNextPage]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            //            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
