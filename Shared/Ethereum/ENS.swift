// Copyright © 2022 Tokenary. All rights reserved.

import Foundation
import Alamofire
import SwiftyJSON

// - MARK: Core

class ENS {
    static let shared = ENS()
    private let queue = DispatchQueue(label: "ENS", qos: .default)

    private init() {}

    func resolveAddress(address: String, completion: @escaping (String?) -> Void) throws {
        let url = self.getUrl(append: address)

        queue.async {
            AF.request(url, method: .get, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        let json = try! JSON(data: data)
                        let value = json["reverseRecord"].stringValue
                        DispatchQueue.main.async {
                            completion(value)
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    break
                }
            }
        }
    }

    private func getUrl(append: String) -> String {
        return "\(ENSApiSettings.baseUrl)\(append)"
    }
}

// - MARK: Settings

struct ENSApiSettings {
    static let baseUrl = "https://ens.fafrd.workers.dev/ens/"
}
