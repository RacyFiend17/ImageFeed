import Foundation

final class OAuth2TokenStorage {
    private let defaults = UserDefaults.standard
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            defaults.string(forKey: tokenKey)
        }
        set {
            defaults.set(newValue, forKey: tokenKey)
        }
    }
}
