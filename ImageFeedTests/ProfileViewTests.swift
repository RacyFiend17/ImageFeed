@testable import ImageFeed
import XCTest
import Foundation

final class ProfileViewTests: XCTestCase {
    
    // MARK: - ProfileViewController tests
    func testViewControllerCallsPresenterViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testDidTapLogoutButtonRequestsPresenterPresentLogout() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.loadViewIfNeeded()
        let buttons = viewController.view.subviews.compactMap { $0 as? UIButton }
        XCTAssertFalse(buttons.isEmpty, "Ожидается хотя бы одна UIButton в иерархии (logoutButton)")
        let logoutButton = buttons.first!
        logoutButton.sendActions(for: .touchUpInside)
        
        //then
        XCTAssertTrue(presenter.presentLogoutAlertCalled)
    }
    
    func testUpdateProfileDetailsUpdatesLabelsText() {
        //given
        let viewController = ProfileViewController()
        let profile = Profile(username: "u", name: "Пётр", loginName: "@petr", bio: "bio text")
        
        //when
        viewController.loadViewIfNeeded()
        viewController.updateProfileDetails(profile: profile)
        
        //then
        let labels = viewController.view.subviews.compactMap { $0 as? UILabel }
        XCTAssertFalse(labels.isEmpty, "Ожидается хотя бы один UILabel в иерархии (logoutButton)")
        let texts = labels.compactMap { $0.text }
        
        XCTAssertTrue(texts.contains("Пётр"))
        XCTAssertTrue(texts.contains("@petr"))
        XCTAssertTrue(texts.contains("bio text"))
    }
    
    func testAlertLogoutConfirmationPresentsUIAlertController() {
        //given
        let viewController = ProfileViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        //when
        viewController.alertLogoutConfirmation { _ in }
        
        //then
        let presented = viewController.presentedViewController
        XCTAssertNotNil(presented)
        XCTAssertTrue(presented is UIAlertController)
    }
    
    
    // MARK: - Presenter tests
    func testProfilePresenterViewDidLoadCallsUpdateProfileDetails() {
        //given
        let fakeProfileService = FakeProfileService()
        fakeProfileService.profile = Profile(username: "u", name: "Иван", loginName: "@ivan", bio: "bio")
        let fakeImageService = FakeProfileImageService()
        let fakeLogout = FakeLogoutService()
        let viewController = ProfileViewControllerSpy()
        
        let presenter = ProfilePresenter(profileService: fakeProfileService,
                                         profileImageService: fakeImageService,
                                         profileLogoutService: fakeLogout)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertEqual(viewController.updatedProfile?.name, "Иван")
        XCTAssertEqual(viewController.updatedProfile?.loginName, "@ivan")
        XCTAssertEqual(viewController.updatedProfile?.bio, "bio")
    }
    
    func testProfilePresenterViewDidLoadCallsUpdateProfileImage() {
        //given
        let fakeProfileService = FakeProfileService()
        fakeProfileService.profile = nil
        let fakeImageService = FakeProfileImageService()
        fakeImageService.avatarURL = "https://example.com/avatar.png"
        let fakeLogout = FakeLogoutService()
        let viewController = ProfileViewControllerSpy()
        
        let presenter = ProfilePresenter(profileService: fakeProfileService,
                                         profileImageService: fakeImageService,
                                         profileLogoutService: fakeLogout)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertNotNil(viewController.updatedImageURL)
        XCTAssertEqual(viewController.updatedImageURL?.absoluteString, "https://example.com/avatar.png")
    }
    
    func testProfilePresenterPresentLogoutAlertConfirmedCallsLogoutAndSwitches() {
        //given
        let fakeProfileService = FakeProfileService()
        let fakeImageService = FakeProfileImageService()
        let fakeLogout = FakeLogoutService()
        let viewController = ProfileViewControllerSpy()
        
        let presenter = ProfilePresenter(profileService: fakeProfileService,
                                         profileImageService: fakeImageService,
                                         profileLogoutService: fakeLogout)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.presentLogoutAlert()
        viewController.simulateLogoutChoice(true)
        
        // assert
        XCTAssertTrue(fakeLogout.logoutCalled, "Logout сервис должен быть вызван")
        XCTAssertTrue(viewController.showLoadingCalled, "showLoading должен быть вызван")
        XCTAssertTrue(viewController.hideLoadingCalled, "hideLoading должен быть вызван")
        XCTAssertTrue(viewController.switchedToSplashCalled, "Должно произойти переключение на Splash")
    }
    
    func testProfilePresenterPresentLogoutAlertCancelledNotCallsLogoutAndNotSwitches() {
        //given
        let fakeProfileService = FakeProfileService()
        let fakeImageService = FakeProfileImageService()
        let fakeLogout = FakeLogoutService()
        let viewController = ProfileViewControllerSpy()
        
        let presenter = ProfilePresenter(profileService: fakeProfileService,
                                         profileImageService: fakeImageService,
                                         profileLogoutService: fakeLogout)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.presentLogoutAlert()
        viewController.simulateLogoutChoice(false)
        
        // assert
        XCTAssertFalse(fakeLogout.logoutCalled, "Logout сервис не должен быть вызван")
        XCTAssertFalse(viewController.showLoadingCalled, "showLoading не должен быть вызван")
        XCTAssertFalse(viewController.hideLoadingCalled, "hideLoading не должен быть вызван")
        XCTAssertFalse(viewController.switchedToSplashCalled, "Не должно произойти переключение на Splash")
    }
    
}


final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    private(set) var showLoadingCalled = false
    private(set) var hideLoadingCalled = false
    private(set) var switchedToSplashCalled = false
    private(set) var updatedProfile: Profile?
    private(set) var updatedImageURL: URL?
    private var logoutCompletion: ((Bool) -> Void)?
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func switchToSplashScreen() {
        switchedToSplashCalled = true
    }
    
    func simulateLogoutChoice(_ confirmed: Bool) {
        logoutCompletion?(confirmed)
    }
    
    func alertLogoutConfirmation(completion: @escaping (Bool) -> Void) {
        logoutCompletion = completion
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        updatedProfile = profile
    }
    
    func updateProfileImage(imageURL: URL) {
        updatedImageURL = imageURL
    }
    
    func showLogoutAlert(alert: UIAlertController) {
        
    }
    
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var presentLogoutAlertCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func presentLogoutAlert() {
        presentLogoutAlertCalled = true
    }
}

final class FakeProfileService: ProfileServiceProtocol {
    var profile: Profile?
    func cleanProfile() {
        profile = nil
    }
}

final class FakeProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
}

final class FakeLogoutService: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false
    func logout() {
        logoutCalled = true
    }
}

