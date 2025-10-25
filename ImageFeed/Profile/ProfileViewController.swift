import UIKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    } ()
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(resource: .ypGray)
        loginNameLabel.text = "@ekaterina_naov"
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginNameLabel
    } ()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.text = "Hello world!"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    } ()
    private var logoutButton = UIButton()
    private var avatarImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        presenter?.viewDidLoad()
    }
    
    func updateProfileImage(imageURL: URL) {

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageURL,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { [weak self] result in
                
                switch result {
                case .success(let value):
                    print("Картинка \(value.image) загружена из источника \(value.source) с размером: \(value.image.size)")
                    print("Картинка загружена из \(value.cacheType)")
                    
                case .failure(let error):
                    print(error)
                    self?.updateProfileImage(imageURL: imageURL)
                }
            }
    }
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }
    
    private func setupLogOutButton()  {
        logoutButton = UIButton.systemButton(
            with: UIImage(resource: .logoutButton),
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        logoutButton.tintColor = UIColor(resource: .ypRed)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func didTapLogoutButton() {
        presenter?.presentLogoutAlert()
    }
    
    func alertLogoutConfirmation(completion: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
            let disagreeAction = UIAlertAction(title: "Нет", style: .default) { _ in completion(false) }
            let agreeAction = UIAlertAction(title: "Да", style: .default) { _ in completion(true) }
            alert.addAction(agreeAction)
            alert.addAction(disagreeAction)
        
            present(alert, animated: true, completion: nil)
        }
    
    func showLoading() {
        ProgressHUD.show()
    }

    func hideLoading() {
        ProgressHUD.dismiss()
    }
    
    func switchToSplashScreen() {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            let splashViewController = SplashViewController()
            UIView.transition(
                with: window,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { window.rootViewController = splashViewController },
                completion: nil)
        }
    
    private func makeAvatarImageView() {
        avatarImageView.image = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func setupConstraints () {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        makeAvatarImageView()
        setupLogOutButton()
        
        view.addSubview(avatarImageView)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        
        setupConstraints()
    }
}

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func updateProfileImage(imageURL: URL)
    func alertLogoutConfirmation(completion: @escaping (Bool) -> Void)
    func showLoading()
    func hideLoading()
    func switchToSplashScreen()
}
