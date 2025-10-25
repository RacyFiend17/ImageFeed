import Foundation
import WebKit

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
       cleanCookies()
       cleanProfile()
       cleanToken()
       cleanImagesList()
   }
    
    private func cleanToken() {
        OAuth2Service.shared.cleanToken()
    }
    
    private func cleanImagesList() {
        ImagesListService.shared.cleanImagesList()
    }
    
    private func cleanProfile() {
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanProfileImage()
    }

    private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}

public protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}
