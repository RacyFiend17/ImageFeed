import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var imagesListService: ImagesListServiceProtocol
    var view: ImagesListViewControllerProtocol?
    
    private var photos: [Photo] = []
    private var imagesListObserver: NSObjectProtocol?
    private let today = Date()
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    } ()
    
    init (imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    deinit {
        if let observer = imagesListObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func viewDidLoad() {
        imagesListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.handleServicePhotosUpdate()
                return
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    private func handleServicePhotosUpdate() {
        let oldPhotosCount = self.photos.count
        self.photos = imagesListService.photos
        let newPhotosCount = self.photos.count
        
        guard newPhotosCount > oldPhotosCount else { return }
        
        let indexPaths: [IndexPath] = (oldPhotosCount..<newPhotosCount).map(){
            IndexPath(row: $0, section: 0)
        }
            view?.insertRows(at: indexPaths)
    }
    
    func numberOfRows() -> Int {
        return photos.count
    }
    
    func largeURLStringAt(index: Int) -> String {
        return photos[index].largeImageURL
    }
    
    func dateTextAt(index: Int) -> String {
            guard let date = photoAt(index: index)?.createdAt else {
                return dateFormatter.string(from: today)
            }
            return dateFormatter.string(from: date)
        }
    
    func isLikedAt(index: Int) -> Bool {
            photoAt(index: index)?.isLiked ?? false
        }
    
    private func photoAt(index: Int) -> Photo? {
            guard index >= 0 && index < photos.count else { return nil }
            return photos[index]
        }
    
    func todayDateFormattedString() -> String {
        return dateFormatter.string(from: today)
    }
    
    func photoSizeAt(index: Int) -> CGSize {
        return photos[index].size
    }
    
    func willDisplayLastRowIfNeeded(currentIndex: Int){
        if currentIndex == photos.count - 1  {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at index: Int, completion: @escaping (Bool) -> Void) {
        guard index >= 0 && index < photos.count else { return }
        let photo = photos[index]
        let newLikeState = !photo.isLiked
        
        view?.showLoading()
        
        let photoID = photos[index].id
        let isLike = photos[index].isLiked
    
        imagesListService.changeLike(photoID: photoID, isLike: isLike){ [weak self] result in
            
            guard let self else { return }
            
            self.view?.dismissLoading()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                completion(newLikeState)
            case .failure(let error):
                print("[imageListCellDidTapLike]: error: \(error)")
                self.view?.showErrorAlert()
            }
        }
    }
}


public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func numberOfRows() -> Int
    func largeURLStringAt(index: Int) -> String
    func dateTextAt(index: Int) -> String
    func isLikedAt(index: Int) -> Bool
    func photoSizeAt(index: Int) -> CGSize
    func willDisplayLastRowIfNeeded(currentIndex: Int)
    func todayDateFormattedString() -> String
    func didTapLike(at index: Int, completion: @escaping (Bool) -> Void)
}
