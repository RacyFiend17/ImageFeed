import UIKit

final class AuthViewController: UIViewController {
    private let segueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
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
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") 
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    vc.dismiss(animated: true)
                    print("Successfully authenticated!")
                }
            case .failure(let error):
                print("Failed to fetch token: \(error)")
            }
        }
        
    }
}

