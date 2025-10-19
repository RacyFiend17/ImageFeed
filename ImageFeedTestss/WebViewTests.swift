@testable import ImageFeed
import XCTest
import Foundation

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoad() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.9
        
        //when
        let shouldHideProgressView = presenter.shouldHideProgressView(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgressView)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgressView = presenter.shouldHideProgressView(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgressView)
    }
    
    final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
        var presenter: WebViewPresenterProtocol?
        
        var loadRequestCalled: Bool = false
        
        func load(request: URLRequest) {
            loadRequestCalled = true
        }
        
        func setProgressValue(_ newValue: Float) {

        }
        
        func setProgressHidden(_ isHidden: Bool) {
            
        }
    }
    
    final class WebViewPresenterSpy: WebViewPresenterProtocol {
        
        var view: WebViewViewControllerProtocol?
        
        var viewDidLoadCalled: Bool = false
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func didUpdateProgressValue(_ newValue: Double) {
            
        }
        
        func code(from url: URL) -> String? {
            return nil
        }
    }
}
