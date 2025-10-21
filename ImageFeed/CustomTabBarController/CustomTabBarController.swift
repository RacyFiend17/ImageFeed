import SwiftUI

final class CustomTabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let logoutService = ProfileLogoutService.shared
        let profilePresenter = ProfilePresenter(
                   profileService: profileService,
                   profileImageService: profileImageService,
                   profileLogoutService: logoutService
               )
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        profileViewController.tabBarItem = UITabBarItem(
                   title: "",
                   image: UIImage(resource: .profileActive),
                   selectedImage: nil
               )

        viewControllers = [imagesListViewController, profileViewController]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "YP Black")
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
