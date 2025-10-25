@testable import ImageFeed
import XCTest

final class ImagesListPresenterTests: XCTestCase {
    
    
    // MARK: - Tests
    
    func testViewDidLoadCallsFetchPhotosNextPage() {
        //given
        let fakeService = FakeImagesListService()
        let presenter = ImagesListPresenter(imagesListService: fakeService)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(fakeService.fetchCalled, "Presenter should request next page on viewDidLoad()")
    }
    
    func testWhenServicePostsUpdatePresenterCalculatesIndexPathsAndCallsViewInsertRows() {
        //given
        let fakeService = FakeImagesListService()
        let presenter = ImagesListPresenter(imagesListService: fakeService)
        let fakeViewController = FakeImagesListViewController()
        presenter.view = fakeViewController
        
        //when
        presenter.viewDidLoad()
        
        let p1 = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t1", largeImageURL: "l1", isLiked: false)
        let p2 = Photo(id: "2", size: CGSize(width: 120, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t2", largeImageURL: "l2", isLiked: false)
        let p3 = Photo(id: "3", size: CGSize(width: 200, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t3", largeImageURL: "l3", isLiked: false)
        
        let expectation = expectation(description: "wait for notification handling")
        DispatchQueue.main.async {
            fakeService.simulatePhotosUpdate(newPhotos: [p1, p2, p3])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
        
        //then
        guard let indexPaths = fakeViewController.insertRowsCalledWith else {
            XCTFail("Expected view.insertRows to be called")
            return
        }
        XCTAssertEqual(indexPaths.count, 3)
        XCTAssertEqual(indexPaths.map { $0.row }, [0,1,2])
    }
    
    func testNumberOfRowsReflectsServicePhotosAfterUpdate() {
        //given
        let fakeService = FakeImagesListService()
        let presenter = ImagesListPresenter(imagesListService: fakeService)
        presenter.view = FakeImagesListViewController()
        presenter.viewDidLoad()
        
        let photos: [Photo] = [
            Photo(id: "a", size: CGSize(width: 10, height: 10), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t", largeImageURL: "l", isLiked: false),
            Photo(id: "b", size: CGSize(width: 10, height: 20), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t", largeImageURL: "l", isLiked: false)
        ]
        
        let exp = expectation(description: "update")
        DispatchQueue.main.async {
            fakeService.simulatePhotosUpdate(newPhotos: photos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { exp.fulfill() }
        }
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(presenter.numberOfRows(), 2)
        XCTAssertEqual(presenter.largeURLStringAt(index: 0), "l")
    }
    
    func testDidTapLikeSuccessShowsAndHidesLoadingAndCallsCompletionWithNewState() {
        //given
        let fakeService = FakeImagesListService()
        
        let photo = Photo(id: "p1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "t", largeImageURL: "l", isLiked: false)
        fakeService.photos = [photo]
        
        let presenter = ImagesListPresenter(imagesListService: fakeService)
        let fakeView = FakeImagesListViewController()
        presenter.view = fakeView
        
        //when
        presenter.viewDidLoad()
        
        let expectationPresenterHandles = expectation(description: "presenter handles photos update from ImagesListService")
        DispatchQueue.main.async {
            fakeService.simulatePhotosUpdate(newPhotos: [photo])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                expectationPresenterHandles.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
        
        let expectationLikeChangeCompleted = expectation(description: "like completion")
        presenter.didTapLike(at: 0) { newState in
            XCTAssertTrue(newState)
            expectationLikeChangeCompleted.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        //then
        XCTAssertTrue(fakeView.showLoadingCalled, "Presenter should ask view to show loading")
        XCTAssertTrue(fakeView.dismissLoadingCalled, "Presenter should ask view to dismiss loading")
        XCTAssertFalse(fakeView.showErrorAlertCalled, "No error expected")
        
        XCTAssertEqual(fakeService.changeLikeCalledWith?.photoID, "p1")
    }
}
    
    // MARK: - Fakes / Spies
    
    private final class FakeImagesListService: ImagesListServiceProtocol {
        var photos: [Photo] = []
        private(set) var fetchCalled = false
        
        var changeLikeShouldSucceed = true
        var changeLikeCalledWith: (photoID: String, isLike: Bool)?
        
        func fetchPhotosNextPage() {
            fetchCalled = true
        }
        
        func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
            changeLikeCalledWith = (photoID: photoID, isLike: isLike)
            if changeLikeShouldSucceed {
                
                if let index = photos.firstIndex(where: { $0.id == photoID }) {
                    let p = photos[index]
                    let newPhoto = Photo(
                        id: p.id,
                        size: p.size,
                        createdAt: p.createdAt,
                        welcomeDescription: p.welcomeDescription,
                        thumbImageURL: p.thumbImageURL,
                        largeImageURL: p.largeImageURL,
                        isLiked: !p.isLiked
                    )
                    photos[index] = newPhoto
                }
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "FakeError", code: -1)))
            }
        }
        
        func simulatePhotosUpdate(newPhotos: [Photo]) {
            self.photos = newPhotos
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["PhotosArray": self.photos]
                )
            }
        }
    }
    
private final class FakeImagesListViewController: ImagesListViewControllerProtocol {
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
    
        var presenter: ImagesListPresenterProtocol?
        
        private(set) var insertRowsCalledWith: [IndexPath]?
        private(set) var showLoadingCalled = false
        private(set) var dismissLoadingCalled = false
        private(set) var showErrorAlertCalled = false
        
        func insertRows(at indexPaths: [IndexPath]) {
            insertRowsCalledWith = indexPaths
        }
        
        func showLoading() {
            showLoadingCalled = true
        }
        
        func dismissLoading() {
            dismissLoadingCalled = true
        }
        
        func showErrorAlert() {
            showErrorAlertCalled = true
        }
    }
    

