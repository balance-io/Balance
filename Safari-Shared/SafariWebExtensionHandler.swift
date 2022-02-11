// Copyright © 2021 Tokenary. All rights reserved.

import SafariServices

let SFExtensionMessageKey = "message"

fileprivate func toJSON(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    private var context: NSExtensionContext?
    private let queue = DispatchQueue(label: "SafariWebExtensionHandler", qos: .default)
    
    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems[0] as? NSExtensionItem,
              let message = item.userInfo?[SFExtensionMessageKey],
              let id = (message as? [String: Any])?["id"] as? Int else { return }
        
        let subject = (message as? [String: Any])?["subject"] as? String
        if subject == "getAccounts" {
            let manager = WalletsManager()
            do {
                try manager.start()
                self.context = context
                let addresses = try manager.wallets.map { wallet -> String in
                    guard let address = wallet.ethereumAddress else { throw "Failed retreiving Ethereum address" }
                    return address
                }
                guard let json = toJSON(from: addresses) else { throw "JSON serialization failed" }
                respond(with: .init(id: id, name: "getAccounts", result: json))
            } catch {
                respond(with: .init(id: id, name: "getAccounts", error: "An error occurred when fetching accounts: \(error.localizedDescription)"))
            }
        } else if subject == "getResponse" {
            #if !os(macOS)
            if let response = ExtensionBridge.getResponse(id: id) {
                self.context = context
                respond(with: response)
                ExtensionBridge.removeResponse(id: id)
            }
            #endif
        } else if subject == "didCompleteRequest" {
            ExtensionBridge.removeResponse(id: id)
        } else if let data = try? JSONSerialization.data(withJSONObject: message, options: []),
                  let query = String(data: data, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let request = SafariRequest(query: query),
                  let url = URL(string: "balance://safari?request=\(query)") {
            self.context = context
            if request.method == .switchEthereumChain || request.method == .addEthereumChain {
                if let chain = request.switchToChain {
                    let response = ResponseToExtension(id: request.id,
                                                       name: request.name,
                                                       results: [request.address],
                                                       chainId: chain.hexStringId,
                                                       rpcURL: chain.nodeURLString)
                    respond(with: response)
                } else {
                    let response = ResponseToExtension(id: request.id, name: request.name, error: "Failed to switch chain")
                    respond(with: response)
                }
            } else {
                ExtensionBridge.makeRequest(id: id)
                #if os(macOS)
                NSWorkspace.shared.open(url)
                #endif
                poll(id: id)
            }
        }
    }
    
    private func poll(id: Int) {
        if let response = ExtensionBridge.getResponse(id: id) {
            respond(with: response)
            #if os(macOS)
            ExtensionBridge.removeResponse(id: id)
            #endif
        } else {
            queue.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.poll(id: id)
            }
        }
    }
    
    private func respond(with response: ResponseToExtension) {
        let item = NSExtensionItem()
        item.userInfo = [SFExtensionMessageKey: response.json]
        context?.completeRequest(returningItems: [item], completionHandler: nil)
        context = nil
    }
    
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
