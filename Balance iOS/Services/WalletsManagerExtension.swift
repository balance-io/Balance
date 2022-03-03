import Foundation
import Constants
import SparrowKit
import UIKit
import SPAlert

extension WalletsManager {
    
    static var recentAddresses: [String] {
        return [
            "0xEAB6923a7af94Af62A6501d88EF2F10163dA2EFa",
            "0x2dfd78cb21a066af3426ce0e5eb10203a84a6a56",
            "0x29632f3bf3242a2e63e9aff785f22d5db8d72a6d",
            "0x05dd6d718871a41e51df0e6624cb8c06c80b09b2",
            "0x0327a21564f427ed77c81e45376a47600b5d3e89",
            "0xa4b10ac61e79ea1e150df70b8dda53391928fd14"
        ]
    }
    
    static func startDestroyProcess(on controller: UIViewController, sourceView: UIView, completion: @escaping (_ destroyed: Bool)->Void) {
        AlertService.confirm(
            title: Texts.Wallet.Destroy.confirm_title,
            description: Texts.Wallet.Destroy.confirm_description, actionTitle: Texts.Wallet.Destroy.action, desctructive: true, action: { confirmed in
                if confirmed {
                    completlyDestroyData()
                    completion(true)
                } else {
                    completion(false)
                }
            },
            sourceView: sourceView,
            presentOn: controller
        )
    }
    
    private static func completlyDestroyData() {
        do {
            try? WalletsManager.shared.destroy()
        }
        Keychain.shared.removePassword()
        Flags.seen_tutorial = false
        Flags.show_safari_extension_advice = true
        AppDelegate.migration()
        NotificationCenter.default.post(name: .walletsUpdated, object: nil)
    }
}
