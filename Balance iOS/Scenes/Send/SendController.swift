import SparrowKit
import UIKit
import SPDiffable
import Constants
import NativeUIKit
import SPSafeSymbols
import SPIndicator

class SendController: SPDiffableTableController {
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = Texts.Wallet.send_title + " (Development)"
        view.backgroundColor = .systemGroupedBackground
        
        tableView.register(SendRecipientTableCell.self)
        tableView.register(WalletTableViewCell.self)
        tableView.contentInset.bottom = NativeLayout.Spaces.Scroll.bottom_inset_reach_end
        
        if let navigationController = self.navigationController as? NativeNavigationController {
            let toolBarView = NativeLargeActionToolBarView()
            toolBarView.actionButton.set(title: Texts.Wallet.send_action, icon: .init(SPSafeSymbol.paperplane.fill), colorise: .tintedColorful)
            navigationController.mimicrateToolBarView = toolBarView
        }
        
        configureDiffable(
            sections: content,
            cellProviders: [.wallet, .network] + SPDiffableTableDataSource.CellProvider.default + [
                .init(clouser: { tableView, indexPath, item in
                    guard let _ = item as? DiffableSendRecipientItem else { return nil }
                    let cell = tableView.dequeueReusableCell(withClass: SendRecipientTableCell.self, for: indexPath)
                    cell.pasteButton.addAction(.init(handler: { _ in
                        let text = UIPasteboard.general.string ?? .space
                        if text.hasPrefix("0x") {
                            SPIndicator.present(title: "Pasted", preset: .done)
                            cell.textView.text = text
                        } else {
                            SPIndicator.present(title: "No address in clipboard", preset: .error)
                        }
                    }), for: .touchUpInside)
                    cell.scanButton.addAction(.init(handler: { _ in
                        Presenter.App.showQRCodeScanningController(completion: { string, controller in
                            if string.hasPrefix("0x") {
                                cell.textView.text = string
                                controller.dismissAnimated()
                            } else {
                                controller.qrScannerView.rescan()
                            }
                        }, on: self)
                    }), for: .touchUpInside)
                    cell.recentButton.addAction(.init(handler: { _ in
                        let recentController = RecentAddressesController(didSelectAddress: { address, controller in
                            controller.dismissAnimated()
                            cell.textView.text = address
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
                    SPDiffableTableRow(
                        text: "Ether",
                        detail: "ETH",
                        icon: .generateSettingsIcon(
                            SPSafeSymbol.wallet.passFill.name,
                            backgroundColor: .systemIndigo
                        ),
                        accessoryType: .disclosureIndicator,
                        selectionStyle: .none,
                        action: nil
                    ),
                    SPDiffableTableRowTextField(
                        id: "amount",
                        text: nil,
                        placeholder: "Amount",
                        autocorrectionType: .no,
                        keyboardType: .decimalPad,
                        autocapitalizationType: .none,
                        clearButtonMode: .always,
                        delegate: nil
                    ),
                    SPDiffableTableRowSubtitle(
                        text: choosedChain.name,
                        subtitle: choosedChain.symbol,
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
}
