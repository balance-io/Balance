import SparrowKit
import UIKit
import SPDiffable
import Constants
import NativeUIKit
import SPSafeSymbols
import SPIndicator
import SPAlert
import SafariServices
import BigInt

class SendController: SPDiffableTableController {
    
    // MARK: - Data
    
    private var address: String? {
        didSet {
            print("new address \(self.address)")
            updateAvability()
        }
    }
    
    private var amount: Double? {
        didSet {
            print("new amount \(self.amount)")
            updateAvability()
        }
    }
    
    // MARK: - Init
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data
    
    internal var wallets = WalletsManager.shared.wallets
    internal var choosedWallet = WalletsManager.shared.wallets.first
    private var choosedChain = Flags.last_selected_network
    
    // MARK: - Views
    
    let toolBarView = NativeLargeActionToolBarView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = Texts.Wallet.send_title + " (Development)"
        view.backgroundColor = .systemGroupedBackground
        
        tableView.register(SendRecipientTableCell.self)
        tableView.register(SendAmountTableCell.self)
        tableView.register(WalletTableViewCell.self)
        tableView.contentInset.bottom = NativeLayout.Spaces.Scroll.bottom_inset_reach_end
        
        if let navigationController = self.navigationController as? NativeNavigationController {
            
            let getCell = { () -> SendRecipientTableCell? in
                for cell in self.tableView.visibleCells {
                    if let cell = cell as? SendRecipientTableCell {
                        return cell
                    }
                }
                return nil
            }
            
            toolBarView.actionButton.set(title: Texts.Wallet.send_action, icon: .init(SPSafeSymbol.paperplane.fill), colorise: .tintedColorful)
            toolBarView.actionButton.isEnabled = false
            toolBarView.actionButton.addAction(.init(handler: { _ in
                let chain = self.choosedChain
                guard let wallet = self.choosedWallet,
                      let address = wallet.ethereumAddress,
                      let cell = getCell(),
                      cell.textView.text.isETHAddress,
                      let amount = self.amount else {
                    self.showErrorAlert("Missing data in request (send)")
                    return
                }
                
                let split = String(amount).components(separatedBy: ".")
                let integer = split[0].count == 0 ? "0" : split[0]
                let fraction = split[1].padding(toLength: 18, withPad: "0", startingAt: 0)
                guard let bigint = BigUInt("\(integer)\(fraction)") else {
                    self.showErrorAlert("BigUInt nil")
                    return
                }
                
                let transaction = Transaction(from: address.lowercased(), to: cell.textView.text.lowercased(), value: "0x\(String(bigint, radix: 16))", data: "0x")
                Presenter.Crypto.Extension.showApproveSendTransaction(
                    transaction: transaction,
                    chain: chain,
                    address: address,
                    peerMeta: nil,
                    approveCompletion: { controller, approved in
                        controller.dismissAnimated()
                        let ethereum = Ethereum.shared
                        if approved {
                            do {
                                let transactionHash = try ethereum.send(transaction: controller.transaction, wallet: wallet, chain: chain)
                                
                                WalletsManager.addToRecentAddress(
                                    WalletsManager.RecentAddressData(
                                        address: cell.textView.text,
                                        amount: amount,
                                        chain: chain
                                    )
                                )
                                
                                let controller = SFSafariViewController(url: .init(string: "\(chain.explorerURLString)/tx/\(transactionHash)")!)
                                controller.dismissAnimated() {
                                    self.present(controller, animated: true, completion: nil)
                                }
                                
                                self.amount = 0
                                SPIndicator.present(title: "Sent", preset: .done, haptic: .success)
                                for cell in self.tableView.visibleCells {
                                    if let cell = cell as? SendRecipientTableCell {
                                        cell.textView.text = nil
                                    }
                                    if let indexPath = self.diffableDataSource?.getIndexPath(id: "amount") {
                                        if let cell = self.tableView.cellForRow(at: indexPath) as? SendAmountTableCell {
                                            cell.textField.text = nil
                                        }
                                    }
                                }
                                self.updateAvability()
                            } catch {
                                self.showErrorAlert(error.localizedDescription)
                                controller.dismissAnimated()
                                return
                            }
                        } else {
                            controller.dismissAnimated()
                        }
                    }, on: self)

                // Temp for update UI
            }), for: .touchUpInside)
            navigationController.mimicrateToolBarView = toolBarView
        }
        
        configureDiffable(
            sections: content,
            cellProviders: [
                .wallet,
                .network,
                .init(clouser: { tableView, indexPath, item in
                    guard let item = item as? SPDiffableTableRowTextField, item.id == "amount" else { return nil }
                    
                    let cell = tableView.dequeueReusableCell(withClass: SendAmountTableCell.self, for: indexPath)
                    
                    cell.textField.delegate = item.delegate
                    cell.textField.placeholder = item.placeholder
                    cell.textField.text = item.text
                    cell.textField.autocorrectionType = item.autocorrectionType
                    cell.textField.keyboardType = item.keyboardType
                    cell.textField.autocapitalizationType = item.autocapitalizationType
                    cell.textField.clearButtonMode = item.clearButtonMode
                    
                    cell.symbol.text = self.choosedChain.symbol
                    
                    return cell
                }),
            ] + SPDiffableTableDataSource.CellProvider.default + [
                .init(clouser: { tableView, indexPath, item in
                    guard let _ = item as? DiffableSendRecipientItem else { return nil }
                    let cell = tableView.dequeueReusableCell(withClass: SendRecipientTableCell.self, for: indexPath)
                    cell.textView.delegate = self
                    cell.textView.text = self.address
                    cell.pasteButton.addAction(.init(handler: { _ in
                        let text = UIPasteboard.general.string ?? .space
                        if text.isETHAddress {
                            self.address = text
                            cell.textView.text = self.address
                            SPIndicator.present(title: "Pasted", preset: .done)
                        } else {
                            SPIndicator.present(title: "No ETH Address in clipboard", preset: .error)
                        }
                    }), for: .touchUpInside)
                    cell.scanButton.addAction(.init(handler: { _ in
                        Presenter.App.showQRCodeScanningController(completion: { string, controller in
                            if string.isETHAddress {
                                self.address = string
                                cell.textView.text = self.address
                                controller.dismissAnimated()
                            } else {
                                controller.qrScannerView.rescan()
                            }
                        }, on: self)
                    }), for: .touchUpInside)
                    cell.recentButton.isEnabled = !WalletsManager.getRecentAddress().isEmpty
                    cell.recentButton.addAction(.init(handler: { _ in
                        let recentController = RecentAddressesController(didSelectAddress: { address, controller in
                            controller.dismissAnimated()
                            self.address = address
                            cell.textView.text = self.address
                        })
                        let popoverController = SPPopoverNavigationController(
                            rootViewController: recentController,
                            size: .init(width: 400, height: 220),
                            sourceView: cell.buttonBarView,
                            sourceRect: .init(x: .zero, y: .zero, width: cell.buttonBarView.frame.width, height: .zero),
                            permittedArrowDirections: .down
                        )
                        self.present(popoverController)
                    }), for: .touchUpInside)
                    return cell
                })
            ],
            headerFooterProviders: [.largeHeader]
        )
        
        dismissKeyboardWhenTappedAround()
    }
    
    private func showErrorAlert(_ error: String? = nil) {
        SPAlert.present(message: error ?? Texts.Wallet.operation_faild, haptic: .error, completion: nil)
    }
    
    // MARK: - Diffable
    
    internal var content: [SPDiffableSection] {
        
        var fromItems: [SPDiffableItem] = []
        if let choosedWallet = self.choosedWallet {
            fromItems.append(
                SPDiffableWrapperItem(id: choosedWallet.id, model: choosedWallet) { item, indexPath in
                    guard let navigationController = self.navigationController else { return }
                    Presenter.Crypto.chooseWallet(didSelectWallet: { wallet in
                        self.choosedWallet = wallet
                        self.diffableDataSource?.set(self.content, animated: true, completion: nil)
                        navigationController.popToRootViewController(animated: true)
                    }, on: navigationController)
                }
            )
        }
        
        return [
            .init(
                id: "from",
                header: SPDiffableTextHeaderFooter(text: "From Wallet"),
                footer: SPDiffableTextHeaderFooter(text: "Before send check network and amount. If need you can change wallet."),
                items: fromItems
            ),
            .init(
                id: "amount",
                header: nil,
                footer: nil,
                items: [
//                    SPDiffableTableRow(
//                        text: "Ether",
//                        detail: "ETH",
//                        icon: .generateSettingsIcon(
//                            SPSafeSymbol.wallet.passFill.name,
//                            backgroundColor: .systemIndigo
//                        ),
//                        accessoryType: .disclosureIndicator,
//                        selectionStyle: .none,
//                        action: nil
//                    ),
                    SPDiffableTableRowTextField(
                        id: "amount",
                        text: amount == nil ? nil : String(amount!),
                        placeholder: "Amount",
                        autocorrectionType: .no,
                        keyboardType: .decimalPad,
                        autocapitalizationType: .none,
                        clearButtonMode: .always,
                        delegate: self
                    ),
                    SPDiffableTableRow(
                        text: choosedChain.name,
                        accessoryType: .disclosureIndicator,
                        selectionStyle: .default,
                        action: { item, indexPath in
                            guard let navigationController = self.navigationController else { return }
                            Presenter.Crypto.Extension.showChangeNetwork(didSelectNetwork: { choosedChain in
                                self.choosedChain = choosedChain
                                self.diffableDataSource?.set(self.content, animated: true, completion: nil)
                                navigationController.popToRootViewController(animated: true)
                            }, on: navigationController)
                        }
                    )
                ]
            ),
            .init(
                id: "to-section",
                header: SPDiffableTextHeaderFooter(text: "To Wallet"),
                footer: nil,
                items: [
                    DiffableSendRecipientItem()
                ]
            ),
        ]
    }
    
    func updateAvability() {
        for cell in tableView.visibleCells {
            if let cell = cell as? SendRecipientTableCell {
                cell.recentButton.isEnabled = !WalletsManager.getRecentAddress().isEmpty
            }
        }
        
        let validETHAddress = address?.isETHAddress ?? false
        let isReadyToSend = validETHAddress && amount != nil && amount! > 0
        self.toolBarView.actionButton.isEnabled = isReadyToSend
    }
}

extension SendController: UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.superview?.superview is SendAmountTableCell {
            let text = (textField.text ?? .empty).replace(",", with: ".")
            self.amount = Double(text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.superview?.superview is SendRecipientTableCell {
            self.address = textView.text
        }
    }
}
