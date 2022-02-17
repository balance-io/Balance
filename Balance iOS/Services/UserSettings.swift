import UIKit

enum UserSettings {
    
    static var tint: UIColor {
        get {
            return .systemBlue
        }
    }
    
    static var added_default_wallet: Bool {
        get {
            return UserDefaults.standard.value(forKey: "added_default_wallet") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "added_default_wallet")
        }
    }
}
