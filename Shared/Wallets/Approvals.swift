import Foundation

fileprivate typealias ApprovalsDictionary = [String: [String]]

enum Approvals {
    
    private static let key = "approvals"
    
    private static let defaults = UserDefaults(suiteName: "group.io.balance")!
    
    private static var dictionary: ApprovalsDictionary {
        get {
            defaults.dictionary(forKey: key) as? ApprovalsDictionary ?? [:]
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }

    static func approve(account: String, on host: String) {
        var approvals = getApprovals(for: host)
        approvals.append(account.lowercased())
        dictionary[host] = approvals
    }

    static func getApprovals(for host: String) -> [String] {
        return dictionary[host] ?? []
    }

    static func removeApproval(for account: String, on host: String) {
        dictionary[host] = getApprovals(for: host).filter { $0 != account.lowercased() }
    }

    static func clearAllApprovals(for account: String) {
        var dictionary = dictionary
        for key in dictionary.keys {
            guard var array = dictionary[key], let index = array.firstIndex(of: account.lowercased()) else { continue }
            array.remove(at: index)
            dictionary[key] = array
        }
        self.dictionary = dictionary
    }
    
    static func destroy() {
        self.dictionary = [:]
    }

}
