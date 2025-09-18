import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    private let segueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    weak var delegate: AuthViewViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(segueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
}

protocol AuthViewViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        ProgressHUD.show()  
        oAuth2Service.fetchOAuthToken(code: code) { [self] result in
            ProgressHUD.dismiss()
            switch result {
            case .success:
                delegate?.didAuthenticate(self)
                print("Successfully authenticated!")
            case .failure(let error):
                print("Failed to fetch token: \(error)")
            }
        }
        
        
    }
}

