import Foundation
import ProgressHUD

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    init(profileService: ProfileServiceProtocol, profileImageService: ProfileImageServiceProtocol, profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileImageService = profileImageService
        self.profileService = profileService
        self.profileLogoutService = profileLogoutService
    }
    
    func viewDidLoad() {
        updateProfileDetails()
        updateProfileImage()
    }
    
    private func updateProfileDetails() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        } else {
            print("Profile data is nil")
        }
    }
    
    private func updateProfileImage() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { print("imageUrl is nil"); return }
        
        view?.updateProfileImage(imageURL: imageUrl)
        print("imageUrl: \(imageUrl)")
    }
    
    func presentLogoutAlert() {
        view?.alertLogoutConfirmation { [weak self] confirmed in
            guard let self = self else { return }
            if confirmed {
                self.performLogoutConfirmed()
            }
        }
    }
    
    private func performLogoutConfirmed() {
        view?.showLoading()
        profileLogoutService.logout()
        view?.switchToSplashScreen()
        view?.hideLoading()
    }
}

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func presentLogoutAlert()
}
