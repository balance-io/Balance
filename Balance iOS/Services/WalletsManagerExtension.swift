import Foundation
import Constants
import SparrowKit
import UIKit
import SPAlert

extension WalletsManager {
    
    struct RecentAddressData {
        
        var address: String
        var amount: Double
        var currency: String
    }
    
    static func addToRecentAddress(_ newData: RecentAddressData) {
        var datas = getRecentAddress().prefix(6)
        
        datas = [newData] + datas
        
        var storage = "";
        let storageSplitter = "expBal_$"
        for data in datas {
            let splitter = "x:x"
            let value = data.address + splitter + "\(data.amount)" + splitter + data.currency
            storage = storage + storageSplitter + value
        }
        UserDefaults.standard.set(storage, forKey: "recent_address_key_3")
    }
    
    static func getRecentAddress() -> [RecentAddressData] {
        let key = UserDefaults.standard.string(forKey: "recent_address_key_3") ?? .empty
        let values = key.components(separatedBy: "expBal_$")
        var datas: [RecentAddressData] = []
        for value in values {
            let fields = value.components(separatedBy: "x:x")
            guard let address = fields[safe: 0] else { continue }
            guard let amountString = fields[safe: 1] else { continue }
            guard let amount = Double(amountString) else { continue }
            guard let currency = fields[safe: 2] else { continue }
            datas.append(.init(address: address, amount: amount, currency: currency))
        }
        return datas
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

extension String {
    
    var isETHAddress: Bool {
        let regex =  "^0x[a-fA-F0-9]{40}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@",regex)
        let result = predicate.evaluate(with: self)
        return result
    }
}
