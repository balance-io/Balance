// Copyright © 2021 Tokenary. All rights reserved.

import SafariServices

let SFExtensionMessageKey = "message"

fileprivate func toJSON(from object:Any) throws -> String {
    guard let result = String(data: try JSONSerialization.data(withJSONObject: object, options: []), encoding: .utf8) else {
        throw "Failed to serialize JSON"
    }
    return result
}

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    private let queue = DispatchQueue(label: "SafariWebExtensionHandler", qos: .default)
    
    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems[0] as? NSExtensionItem,
              let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let id = message["id"] as? Int else { return }
        
        let subject = message["subject"] as? String
        if subject == "getAccounts" {
            let manager = WalletsManager()
            do {
                try manager.start()
                let addresses = try manager.wallets.map { wallet -> String in
                    guard let address = wallet.ethereumAddress else { throw "Failed retreiving Ethereum address" }
                    return address
                }
                let json = try toJSON(from: addresses)
                context.respond(with: .init(id: id, name: "getAccounts", result: json))
            } catch {
                context.respond(with: .init(id: id, name: "getAccounts", error: "An error occurred when fetching accounts: \(error.localizedDescription)"))
            }
        } else if subject == "getChains" {
            do {
                let mainnets = EthereumChain.allMainnets.reduce(into: [String: [String: Any]]()) {
                    $0[String($1.id)] = ["name": $1.name, "symbol": $1.symbol, "rpc": $1.nodeURLString, "isTestnet": false]
                }
                let chains = EthereumChain.allTestnets.reduce(into: mainnets) {
                    $0[String($1.id)] = ["name": $1.name, "symbol": $1.symbol, "rpc": $1.nodeURLString, "isTestnet": true]
                }
                context.respond(with: .init(id: id, name: "getChains", result: try toJSON(from: chains)))
            } catch {
                context.respond(with: .init(id: id, name: "getChains", error: "An error occurred when fetching accounts: \(error.localizedDescription)"))
            }
        } else if subject == "getApprovals" {
            do {
                guard let host = message["host"] as? String, host.count > 0 else { throw "`host` was invalid" }
                context.respond(with: .init(id: id, name: "getApprovals", result: try toJSON(from: Approvals.getApprovals(for: host))))
            } catch {
                context.respond(with: .init(id: id, name: "getApprovals", error: "An error occurred when fetching accounts: \(error.localizedDescription)"))
            }
        } else if subject == "approve" {
            do {
                // TODO: Actually validate address
                guard let account = message["account"] as? String, account.count == 42 else { throw "`account` was invalid" }
                guard let host = message["host"] as? String, host.count > 0 else { throw "`host` was invalid" }
                Approvals.approve(account: account, on: host)
                context.respond(with: .init(id: id, name: "getChains", result: "true"))
            } catch {
                context.respond(with: .init(id: id, name: "getChains", error: "An error occurred when fetching accounts: \(error.localizedDescription)"))
            }
        } else if subject == "getResponse" {
            #if !os(macOS)
            if let response = ExtensionBridge.getResponse(id: id) {
                context.respond(with: response)
                ExtensionBridge.removeResponse(id: id)
            }
            #endif
        } else if subject == "didCompleteRequest" {
            ExtensionBridge.removeResponse(id: id)
        } else if let data = try? JSONSerialization.data(withJSONObject: message, options: []),
                  let query = String(data: data, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let request = SafariRequest(query: query),
                  let url = URL(string: "balance://safari?request=\(query)") {
            if request.method == .switchEthereumChain || request.method == .addEthereumChain {
                if let chain = request.switchToChain {
                    let response = ResponseToExtension(id: request.id,
                                                       name: request.name,
                                                       results: [request.address],
                                                       chainId: chain.hexStringId,
                                                       rpcURL: chain.nodeURLString)
                    context.respond(with: response)
                } else {
                    let response = ResponseToExtension(id: request.id, name: request.name, error: "Failed to switch chain")
                    context.respond(with: response)
                }
            } else {
                ExtensionBridge.makeRequest(id: id)
                #if os(macOS)
                NSWorkspace.shared.open(url)
                #endif
                poll(id: id, context: context)
            }
        }
    }
    
    private func poll(id: Int, context: NSExtensionContext) {
        if let response = ExtensionBridge.getResponse(id: id) {
            context.respond(with: response)
            #if os(macOS)
            ExtensionBridge.removeResponse(id: id)
            #endif
        } else {
            queue.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.poll(id: id, context: context)
            }
        }
    }
    
}

extension NSExtensionContext {
    func respond(with response: ResponseToExtension) {
        let item = NSExtensionItem()
        item.userInfo = [SFExtensionMessageKey: response.json]
        self.completeRequest(returningItems: [item], completionHandler: nil)
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
