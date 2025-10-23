import SwiftUI

final class CustomTabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            assertionFailure("Could not instantiate ImagesListViewController from storyboard")
            return
        }
        let imagesListPresenter = ImagesListPresenter(imagesListService: ImagesListService.shared)
        imagesListViewController.configure(presenter: imagesListPresenter)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter(
                   profileService: ProfileService.shared,
                   profileImageService: ProfileImageService.shared,
                   profileLogoutService: ProfileLogoutService.shared
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
