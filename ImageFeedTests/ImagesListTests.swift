@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsPresenterViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        viewController.setValue(tableView, forKey: "tableView")
        let presenter = PresenterSpy()
        viewController.configure(presenter: presenter)
        
        //when
        viewController.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testTableViewNumberOfRowsUsesPresenterNumberOfRows() {
        //given
        let presenter = PresenterSpy()
        
        let viewController = ImagesListViewController()
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        viewController.setValue(tableView, forKey: "tableView")
        viewController.configure(presenter: presenter)
        
        //when
        let rows = viewController.tableView(tableView, numberOfRowsInSection: 0)
        
        //then
        XCTAssertEqual(rows, 5)
    }
}

final class PresenterSpy: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var numberOfRowsReturn = 5
    var largeURLStringReturn = "https://example.com/image"
    var dateTextReturn = "1 января 2001"
    var photoSizeReturn = CGSize(width: 100, height: 200)
    var isLikedReturn = false
    var todayStringReturn = "21 января 2021"
    var willDisplayLastRowIfNeededCalled = false
    var didTapLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func numberOfRows() -> Int {
        numberOfRowsReturn
    }
    
    func largeURLStringAt(index: Int) -> String {
        largeURLStringReturn
    }
    
    func dateTextAt(index: Int) -> String {
        dateTextReturn
    }
    
    func isLikedAt(index: Int) -> Bool {
        isLikedReturn
    }
    
    func photoSizeAt(index: Int) -> CGSize {
        photoSizeReturn
    }
    
    func willDisplayLastRowIfNeeded(currentIndex: Int) {
        willDisplayLastRowIfNeededCalled = true
    }
    
    func todayDateFormattedString() -> String {
        todayStringReturn
    }
    
    func didTapLike(at index: Int, completion: @escaping (Bool) -> Void) {
        didTapLikeCalled = true
    }
}
